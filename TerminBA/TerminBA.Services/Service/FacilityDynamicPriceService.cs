using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class FacilityDynamicPriceService : BaseCRUDService<FacilityDynamicPriceResponse, FacilityDynamicPrice, FacilityDynamicPriceSearchObject, FacilityDynamicPriceInsertRequest, FacilityDynamicPriceUpdateRequest>, IFacilityDynamicPriceService
    {
        public FacilityDynamicPriceService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<decimal> DynamicPriceForDateAsync(DynamicPriceForDateRequest request)
        {
            var facility = await _context.Facilities
                    .Include(f => f.DynamicPrices)
                    .FirstOrDefaultAsync(f => f.Id == request.FacilityId);

            if (facility == null)
                throw new UserException("Facility not found.");

            var price = DynamicPriceHelper.GetExpectedPrice(
                facility,
                request.ReservationDate,
                request.StartTime,
                request.EndTime);

            return price;
        }

        public override IQueryable<FacilityDynamicPrice> ApplyFilter(IQueryable<FacilityDynamicPrice> query, FacilityDynamicPriceSearchObject search)
        {

            if (search.FacilityId.HasValue)
            {
                query = query.Where(fdp => fdp.FacilityId == search.FacilityId.Value);
            }

            if (search.StartDay.HasValue)
            {
                query = query.Where(fdp => fdp.StartDay == search.StartDay.Value);
            }

            if (search.EndDay.HasValue)
            {
                query = query.Where(fdp => fdp.EndDay == search.EndDay.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(fdp => fdp.IsActive == search.IsActive.Value);
            }

            if (search.ValidFrom.HasValue)
            {
                query = query.Where(fdp => fdp.ValidFrom <= search.ValidFrom.Value);
            }

            if (search.ValidTo.HasValue)
            {
                query = query.Where(fdp => fdp.ValidTo == null || fdp.ValidTo >= search.ValidTo.Value);
            }

            return query;
        }

        protected override FacilityDynamicPriceResponse MapToResponse(FacilityDynamicPrice entity)
        {
            return new FacilityDynamicPriceResponse
            {
                Id = entity.Id,
                FacilityId = entity.FacilityId,
                FacilityName = entity.Facility?.Name, // null if not included

                StartDay = entity.StartDay,
                EndDay = entity.EndDay,

                StartTime = entity.StartTime,
                EndTime = entity.EndTime,

                PricePerHour = entity.PricePerHour,

                IsActive = entity.IsActive, // C# computed property

                ValidFrom = entity.ValidFrom,
                ValidTo = entity.ValidTo
            };
        }

        protected override async Task BeforeInsert(FacilityDynamicPrice entity, FacilityDynamicPriceInsertRequest request)
        {
            ValidateFacilityDynamicPriceRequest(request.StartTime, request.EndTime, request.ValidFrom, request.ValidTo);
            await ValidateWithinSportCenterWorkingHours(request.FacilityId, request.StartDay, request.EndDay, request.StartTime, request.EndTime, request.ValidFrom, request.ValidTo);
        }

        protected override async Task BeforeUpdate(FacilityDynamicPrice entity, FacilityDynamicPriceUpdateRequest request)
        {
            ValidateFacilityDynamicPriceRequest(request.StartTime, request.EndTime, request.ValidFrom, request.ValidTo);
            await ValidateWithinSportCenterWorkingHours(request.FacilityId, request.StartDay, request.EndDay, request.StartTime, request.EndTime, request.ValidFrom, request.ValidTo);
        }

        public override IQueryable<FacilityDynamicPrice> ApplyIncludes(IQueryable<FacilityDynamicPrice> query)
        {
            query=query.Include(f => f.Facility);
            return query;
        }

        private void ValidateFacilityDynamicPriceRequest(TimeOnly startTime, TimeOnly endTime, DateOnly validFrom, DateOnly? validTo)
        {

            if (startTime >= endTime)
            {
                throw new UserException("Start time must be before end time.");
            }

            if (validTo.HasValue && validFrom > validTo.Value)
            {
                throw new UserException("ValidFrom date must be before or equal to ValidTo date.");
            }
        }

        private async Task ValidateWithinSportCenterWorkingHours(int facilityId, DayOfWeek startDay, DayOfWeek endDay, TimeOnly startTime, TimeOnly endTime, DateOnly validFrom, DateOnly? validTo)
        {
            var facility = await _context.Facilities
                .AsNoTracking()
                .Select(f => new { f.Id, f.SportCenterId })
                .FirstOrDefaultAsync(f => f.Id == facilityId);

            if (facility == null)
            {
                throw new UserException("Facility was not found.");
            }

            var workingHours = await _context.WorkingHours
                .Where(wh => wh.SportCenterId == facility.SportCenterId)
                .ToListAsync();

            if (!workingHours.Any())
            {
                throw new UserException("Sport center does not have configured working hours.");
            }

            foreach (var day in GetDaysInRange(startDay, endDay))
            {
                var matchingWorkingHours = workingHours.Where(wh =>
                    TimeSlotHelper.IsInDayRange(day, wh.StartDay, wh.EndDay)
                    && wh.OpeningHours <= startTime
                    && wh.CloseingHours >= endTime);

                var hasMatchingWorkingHours = IsDateRangeCoveredByWorkingHours(validFrom, validTo, matchingWorkingHours);

                if (!hasMatchingWorkingHours)
                {
                    throw new UserException($"Dynamic price time range {startTime:HH\\:mm}-{endTime:HH\\:mm} is outside active working hours for the selected date range.");
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

