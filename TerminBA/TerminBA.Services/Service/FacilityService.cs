using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class FacilityService : BaseCRUDService<FacilityResponse,Facility,FacilitySearchObject,FacilityInsertRequest,FacilityUpdateRequest>, IFacilityService
    {
        private readonly IFacilityDynamicPriceService _facilityDynamicPriceService;

        public FacilityService(TerminBaContext context, IMapper mapper, IFacilityDynamicPriceService facilityDynamicPriceService) : base(context, mapper)
        {
            _facilityDynamicPriceService = facilityDynamicPriceService;
        }

        public override IQueryable<Facility> ApplyFilter(IQueryable<Facility> query, FacilitySearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                var nameLower = search.Name.ToLower();
                query = query.Where(f => f.Name != null && f.Name.ToLower().Contains(nameLower));
            }

            if (search.SportCenterId.HasValue)
            {
                query = query.Where(f => f.SportCenterId == search.SportCenterId.Value);
            }

            if (search.TurfTypeId.HasValue)
            {
                query = query.Where(f => f.TurfTypeId == search.TurfTypeId.Value);
            }

            if (search.IsIndoor.HasValue)
            {
                query = query.Where(f => f.IsIndoor == search.IsIndoor.Value);
            }

            if (search.SportId.HasValue)
            {
                var sportId = search.SportId.Value;
                query = query.Where(f => f.AvailableSports.Any(s => s.Id == sportId));
            }

            if (search.MinPrice.HasValue)
            {
                var minPrice = (decimal)search.MinPrice.Value;

                query = query.Where(f =>
                    // Static pricing: facilities with a static price greater or equal to min
                    (!f.IsDynamicPricing && f.StaticPrice.HasValue && f.StaticPrice.Value >= minPrice)
                    ||
                    // Dynamic pricing: at least one dynamic price greater or equal to min
                    (f.IsDynamicPricing && f.DynamicPrices.Any(dp => dp.PricePerHour >= minPrice))
                );
            }

            if (search.MaxPrice.HasValue)
            {
                var maxPrice = (decimal)search.MaxPrice.Value;

                query = query.Where(f =>
                    // Static pricing: facilities with a static price less or equal to max
                    (!f.IsDynamicPricing && f.StaticPrice.HasValue && f.StaticPrice.Value <= maxPrice)
                    ||
                    // Dynamic pricing: at least one dynamic price less or equal to max
                    (f.IsDynamicPricing && f.DynamicPrices.Any(dp => dp.PricePerHour <= maxPrice))
                );
            }

            return query;
        }

        public override IQueryable<Facility> ApplyIncludes(IQueryable<Facility> query)
        {
            query = query
                .Include(f => f.DynamicPrices);

            return query;
        }


        public override async Task<FacilityResponse> CreateAsync(FacilityInsertRequest request)
        {

            Facility entity = new Facility();

            entity = MapInsertToEntity(entity, request);

            if (request.AvailableSportsIds != null && request.AvailableSportsIds.Any())
            {
                var sports = await _context.Sports
                    .Where(s => request.AvailableSportsIds.Contains(s.Id))
                    .ToListAsync();

                entity.AvailableSports = sports;
            }

            await BeforeInsert(entity, request);

            await _context.Facilities.AddAsync(entity);

            await _context.SaveChangesAsync();

            // The FE won't allow creating dynamic pricing if the chechbox is not selected
            if (request.IsDynamicPricing)
            {
                foreach (var dynamicPriceRequest in request.DynamicPrices)
                {
                    dynamicPriceRequest.FacilityId = entity.Id;
                    await _facilityDynamicPriceService.CreateAsync(dynamicPriceRequest);
                }

                await _context.Entry(entity).Collection(f => f.DynamicPrices).LoadAsync();
            }

            return MapToResponse(entity);
        }

        public async Task<List<FacilityTimeSlot>> GetFacilityTimeSlotAsync(int facilityId, DateOnly pickedDate)
        {
            var allSlots = await TimeSlotHelper.GenerateTimeSlots(facilityId, pickedDate, _context);


            var bookedReservations = await _context.Reservations
                .Where(r => r.FacilityId == facilityId && r.ReservationDate == pickedDate)

                .Select(r => r.StartTime)
                .ToListAsync();


            var occupiedStartTimes = new HashSet<TimeSpan>(
                bookedReservations.Select(ts => ts.ToTimeSpan())
            );


            var facilityTimeSlots = allSlots.Select(t => new FacilityTimeSlot
            {
                StartTime = t.Start,
                EndTime = t.End,

                isFree = !occupiedStartTimes.Contains(t.Start)
            }).ToList();

            return facilityTimeSlots;
        }

    protected override async Task BeforeInsert(Facility entity, FacilityInsertRequest request)
        {
            await ValidateFacilityRequest(request.SportCenterId, request.Name, request.AvailableSportsIds, request.TurfTypeId);
            ValidatePricingRequest(request.IsDynamicPricing, request.StaticPrice);
            ValidateDynamicPricesRequest(request.IsDynamicPricing, request.DynamicPrices);
        }

        protected override async Task BeforeUpdate(Facility entity, FacilityUpdateRequest request)
        {
            await ValidateFacilityRequest(request.SportCenterId, request.Name, request.AvailableSportsIds, request.TurfTypeId);
            ValidatePricingRequest(request.IsDynamicPricing, request.StaticPrice);
        }

        protected override async Task BeforeDelete(Facility entity)
        {
            var reviews = await _context.FacilityReviews
                .Where(fr => fr.FacilityId == entity.Id)
                .ToListAsync();

            if (reviews.Any())
                _context.RemoveRange(reviews);


        }

        private async Task ValidateFacilityRequest(int sportCenterId, string name, List<int> availableSportsIds, int turfTypeId)
        {
            var sportCenter = await _context.SportCenters
                .Select(sc => new { sc.Id, AvailableSportIds = sc.AvailableSports.Select(s => s.Id).ToList() })
                .FirstOrDefaultAsync(sc => sc.Id == sportCenterId);

            if (sportCenter == null)
                throw new UserException($"Sport center was not found.");

            bool nameExists = await _context.Facilities.AnyAsync(f =>
                f.SportCenterId == sportCenterId &&
                f.Name.ToLower() == name.ToLower());

            if (nameExists)
                throw new UserException($"Facility with name: {name} already exits for entered sport center.");

            bool allSportsPresent = availableSportsIds.All(x => sportCenter.AvailableSportIds.Contains(x));

            if (!allSportsPresent)
                throw new UserException($"Sport center does not support all given sports.");

            if (!await _context.TurfTypes.AnyAsync(x => x.Id == turfTypeId))
                throw new UserException($"Turf type was not found.");
        }

        private void ValidatePricingRequest(bool isDynamicPricing, decimal? staticPrice)
        {
            if (!isDynamicPricing && !staticPrice.HasValue)
            {
                throw new UserException("Static price is required when dynamic pricing is disabled.");
            }

            if (isDynamicPricing && staticPrice.HasValue)
            {
                throw new UserException("Static price must be null when dynamic pricing is enabled.");
            }
        }

        private void ValidateDynamicPricesRequest(bool isDynamicPricing, List<FacilityDynamicPriceInsertRequest>? dynamicPrices)
        {
            if (!isDynamicPricing && dynamicPrices != null && dynamicPrices.Any())
            {
                throw new UserException("Dynamic prices cannot be provided when dynamic pricing is disabled.");
            }
        }
    }
}
