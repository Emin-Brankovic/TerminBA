using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;
using TerminBA.Services.ReservationStateMachine;

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
            var today = DateOnly.FromDateTime(DateTime.Today);
            var isActiveExpr = FacilityDynamicPrice.IsActiveExpr(today);
            query = query
                .Include(f => f.DynamicPrices.AsQueryable().Where(isActiveExpr))
                .Include(f => f.TurfType)
                .Include(f => f.AvailableSports);

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
            //if (request.IsDynamicPricing)
            //{
            //    foreach (var dynamicPriceRequest in request.DynamicPrices)
            //    {
            //        dynamicPriceRequest.FacilityId = entity.Id;
            //        await _facilityDynamicPriceService.CreateAsync(dynamicPriceRequest);
            //    }

            //    await _context.Entry(entity).Collection(f => f.DynamicPrices).LoadAsync();
            //}

            return MapToResponse(entity);
        }

        public async Task<List<FacilityTimeSlot>> GetFacilityTimeSlotAsync(int facilityId, DateOnly pickedDate)
        {
            var allSlots = await TimeSlotHelper.GenerateTimeSlots(facilityId, pickedDate, _context);
            DateOnly today = DateOnly.FromDateTime(DateTime.Now);

            var bookedReservations = await _context.Reservations
                .Where(r => r.FacilityId == facilityId && r.ReservationDate == pickedDate && (r.Status == nameof(ActiveReservationState)
                || r.Status == nameof(CompletedReservationState)))

                .Select(r => r.StartTime)
                .ToListAsync();


            var occupiedStartTimes = new HashSet<TimeSpan>(
                bookedReservations.Select(ts => ts.ToTimeSpan())
            );

            var nowTime = DateTime.Now.TimeOfDay;
            var isToday = pickedDate == today;
            var isFutureDate = pickedDate > today;


            var facilityTimeSlots = allSlots.Select(t => new FacilityTimeSlot
            {
                StartTime = t.Start,
                EndTime = t.End,

                isFree = !occupiedStartTimes.Contains(t.Start)
                    && (isFutureDate || (isToday && t.Start > nowTime))
            }).ToList();

            return facilityTimeSlots;
        }

    protected override async Task BeforeInsert(Facility entity, FacilityInsertRequest request)
        {
            await ValidateFacilityRequest(request.SportCenterId, request.Name, request.AvailableSportsIds, request.TurfTypeId);
            ValidatePricingRequest(request.IsDynamicPricing, request.StaticPrice);
            await ValidateDynamicPricesRequest(request.IsDynamicPricing, request.SportCenterId, request.DynamicPrices);
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

        private async Task ValidateDynamicPricesRequest(bool isDynamicPricing, int sportCenterId, List<FacilityDynamicPriceInsertRequest>? dynamicPrices)
        {
            if (!isDynamicPricing && dynamicPrices != null && dynamicPrices.Any())
            {
                throw new UserException("Dynamic prices cannot be provided when dynamic pricing is disabled.");
            }

            if (!isDynamicPricing || dynamicPrices == null || !dynamicPrices.Any())
            {
                return;
            }

            var workingHours = await _context.WorkingHours
                .Where(wh => wh.SportCenterId == sportCenterId)
                .ToListAsync();

            if (!workingHours.Any())
            {
                throw new UserException("Sport center does not have configured working hours.");
            }

            foreach (var dynamicPrice in dynamicPrices)
            {
                if (dynamicPrice.StartTime >= dynamicPrice.EndTime)
                {
                    throw new UserException("Start time must be before end time.");
                }

                if (dynamicPrice.ValidTo.HasValue && dynamicPrice.ValidFrom > dynamicPrice.ValidTo.Value)
                {
                    throw new UserException("ValidFrom date must be before or equal to ValidTo date.");
                }

                foreach (var day in GetDaysInRange(dynamicPrice.StartDay, dynamicPrice.EndDay))
                {
                    var matchingWorkingHours = workingHours.Where(wh =>
                        TimeSlotHelper.IsInDayRange(day, wh.StartDay, wh.EndDay)
                        && wh.OpeningHours <= dynamicPrice.StartTime
                        && wh.CloseingHours >= dynamicPrice.EndTime);

                    var hasMatchingWorkingHours = IsDateRangeCoveredByWorkingHours(
                        dynamicPrice.ValidFrom,
                        dynamicPrice.ValidTo,
                        matchingWorkingHours);

                    if (!hasMatchingWorkingHours)
                    {
                        throw new UserException(
                            $"Dynamic price time range {dynamicPrice.StartTime:HH\\:mm}-{dynamicPrice.EndTime:HH\\:mm} is outside active working hours for the selected date range.");
                    }
                }
            }
        }

        private static bool IsDateRangeCoveredByWorkingHours(DateOnly targetStart, DateOnly? targetEnd, IEnumerable<WorkingHours> workingHours)
        {
            var requiredEndDay = (targetEnd ?? DateOnly.MaxValue).DayNumber;
            var cursorDay = targetStart.DayNumber;
            var maxDayNumber = DateOnly.MaxValue.DayNumber;

            var intervals = workingHours
                .Select(wh => new
                {
                    StartDay = wh.ValidFrom.DayNumber,
                    EndDay = (wh.ValidTo ?? DateOnly.MaxValue).DayNumber
                })
                .Where(x => x.EndDay >= x.StartDay)
                .OrderBy(x => x.StartDay)
                .ThenBy(x => x.EndDay)
                .ToList();

            foreach (var interval in intervals)
            {
                if (interval.EndDay < cursorDay)
                {
                    continue;
                }

                if (interval.StartDay > cursorDay)
                {
                    return false;
                }

                if (interval.EndDay >= requiredEndDay)
                {
                    return true;
                }

                if (interval.EndDay >= maxDayNumber)
                {
                    return true;
                }

                cursorDay = interval.EndDay + 1;
            }

            return false;
        }

        private static IEnumerable<DayOfWeek> GetDaysInRange(DayOfWeek startDay, DayOfWeek endDay)
        {
            var days = new List<DayOfWeek>();
            var current = startDay;

            while (true)
            {
                days.Add(current);

                if (current == endDay)
                {
                    break;
                }

                current = (DayOfWeek)(((int)current + 1) % 7);
            }

            return days;
        }
    }
}
