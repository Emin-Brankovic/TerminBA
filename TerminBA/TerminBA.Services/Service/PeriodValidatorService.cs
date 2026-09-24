using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TerminBA.Models.Exceptions;
using TerminBA.Models.Request;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;
using TerminBA.Models.Model;

namespace TerminBA.Services.Service
{
    public class PeriodValidatorService : IPeriodValidatorService
    {
        private readonly TerminBaContext _context;

        public PeriodValidatorService(TerminBaContext context)
        {
            _context = context;
        }

        public async Task ValidateWorkingHoursInsertAsync(int sportCenterId, WorkingHoursInsertRequest request)
        {
            ValidatePeriod(request.OpeningHours, request.CloseingHours, request.ValidFrom, request.ValidTo);

            var existingWorkingHours = await _context.WorkingHours
                .Where(wh => wh.SportCenterId == sportCenterId)
                .ToListAsync();

            EnsureNoOverlaps(existingWorkingHours, request.StartDay, request.EndDay, request.OpeningHours, request.CloseingHours, request.ValidFrom, request.ValidTo, null);
        }

        public async Task ValidateWorkingHoursUpdateAsync(int recordId, WorkingHoursUpdateRequest request)
        {
            ValidatePeriod(request.OpeningHours, request.CloseingHours, request.ValidFrom, request.ValidTo);

            var existingWorkingHours = await _context.WorkingHours
                .Where(wh => wh.SportCenterId == request.SportCenterId)
                .ToListAsync();

            EnsureNoOverlaps(existingWorkingHours, request.StartDay, request.EndDay, request.OpeningHours, request.CloseingHours, request.ValidFrom, request.ValidTo, recordId);
        }

        public Task ValidateWorkingHoursListAsync(List<WorkingHoursInsertRequest>? workingHours)
        {
            if (workingHours == null || !workingHours.Any())
                return Task.CompletedTask;

            foreach (var wh in workingHours)
            {
                ValidatePeriod(wh.OpeningHours, wh.CloseingHours, wh.ValidFrom, wh.ValidTo);
            }

            for (int i = 0; i < workingHours.Count; i++)
            {
                for (int j = i + 1; j < workingHours.Count; j++)
                {
                    var wh1 = workingHours[i];
                    var wh2 = workingHours[j];

                    if (ArePeriodsConflicting(
                        wh1.ValidFrom, wh1.ValidTo, wh1.StartDay, wh1.EndDay, wh1.OpeningHours, wh1.CloseingHours,
                        wh2.ValidFrom, wh2.ValidTo, wh2.StartDay, wh2.EndDay, wh2.OpeningHours, wh2.CloseingHours))
                    {
                        throw new UserException("Overlapping working-hour records are not allowed for the same sport center.");
                    }
                }
            }

            return Task.CompletedTask;
        }

        public async Task ValidateDynamicPriceInsertAsync(int sportCenterId, FacilityDynamicPriceInsertRequest request)
        {
            ValidatePeriod(request.StartTime, request.EndTime, request.ValidFrom, request.ValidTo, request.Price);

            var existingPrices = await _context.FacilityDynamicPrices
                .Where(fdp => fdp.FacilityId == request.FacilityId)
                .ToListAsync();

            EnsureNoOverlaps(existingPrices, request.StartDay, request.EndDay, request.StartTime, request.EndTime, request.ValidFrom, request.ValidTo, null);

            var workingHours = await _context.WorkingHours
                .Where(wh => wh.SportCenterId == sportCenterId)
                .ToListAsync();

            EnsureWithinWorkingHours(workingHours, request.StartDay, request.EndDay, request.StartTime, request.EndTime, request.ValidFrom, request.ValidTo);
        }

        public async Task ValidateDynamicPriceUpdateAsync(int recordId, int sportCenterId, FacilityDynamicPriceUpdateRequest request)
        {
            ValidatePeriod(request.StartTime, request.EndTime, request.ValidFrom, request.ValidTo, request.Price);

            var existingPrices = await _context.FacilityDynamicPrices
                .Where(fdp => fdp.FacilityId == request.FacilityId)
                .ToListAsync();

            EnsureNoOverlaps(existingPrices, request.StartDay, request.EndDay, request.StartTime, request.EndTime, request.ValidFrom, request.ValidTo, recordId);

            var workingHours = await _context.WorkingHours
                .Where(wh => wh.SportCenterId == sportCenterId)
                .ToListAsync();

            EnsureWithinWorkingHours(workingHours, request.StartDay, request.EndDay, request.StartTime, request.EndTime, request.ValidFrom, request.ValidTo);
        }

        public async Task ValidateDynamicPricesListInsertAsync(bool isDynamicPricing, int sportCenterId, List<FacilityDynamicPriceInsertRequest>? dynamicPrices)
        {
            if (!isDynamicPricing && dynamicPrices != null && dynamicPrices.Any())
                throw new UserException("Dynamic prices cannot be provided when dynamic pricing is disabled.");

            if (!isDynamicPricing || dynamicPrices == null || !dynamicPrices.Any())
                return;

            var workingHours = await _context.WorkingHours
                .Where(wh => wh.SportCenterId == sportCenterId)
                .ToListAsync();

            if (!workingHours.Any())
                throw new UserException("Sport center does not have configured working hours.");

            for (int i = 0; i < dynamicPrices.Count; i++)
            {
                var p1 = dynamicPrices[i];
                ValidatePeriod(p1.StartTime, p1.EndTime, p1.ValidFrom, p1.ValidTo, p1.Price);
                EnsureWithinWorkingHours(workingHours, p1.StartDay, p1.EndDay, p1.StartTime, p1.EndTime, p1.ValidFrom, p1.ValidTo);

                for (int j = i + 1; j < dynamicPrices.Count; j++)
                {
                    var p2 = dynamicPrices[j];
                    if (ArePeriodsConflicting(
                        p1.ValidFrom, p1.ValidTo, p1.StartDay, p1.EndDay, p1.StartTime, p1.EndTime,
                        p2.ValidFrom, p2.ValidTo, p2.StartDay, p2.EndDay, p2.StartTime, p2.EndTime))
                    {
                        throw new UserException("Overlapping dynamic prices are not allowed. Check validity dates, days of the week, and time ranges.");
                    }
                }
            }
        }

        public async Task ValidateDynamicPricesListUpdateAsync(bool isDynamicPricing, int sportCenterId, List<FacilityDynamicPriceUpdateRequest>? dynamicPrices)
        {
            if (!isDynamicPricing && dynamicPrices != null && dynamicPrices.Any())
                throw new UserException("Dynamic prices cannot be provided when dynamic pricing is disabled.");

            if (!isDynamicPricing || dynamicPrices == null || !dynamicPrices.Any())
                return;

            var workingHours = await _context.WorkingHours
                .Where(wh => wh.SportCenterId == sportCenterId)
                .ToListAsync();

            if (!workingHours.Any())
                throw new UserException("Sport center does not have configured working hours.");

            for (int i = 0; i < dynamicPrices.Count; i++)
            {
                var p1 = dynamicPrices[i];
                ValidatePeriod(p1.StartTime, p1.EndTime, p1.ValidFrom, p1.ValidTo, p1.Price);
                EnsureWithinWorkingHours(workingHours, p1.StartDay, p1.EndDay, p1.StartTime, p1.EndTime, p1.ValidFrom, p1.ValidTo);

                for (int j = i + 1; j < dynamicPrices.Count; j++)
                {
                    var p2 = dynamicPrices[j];
                    if (ArePeriodsConflicting(
                        p1.ValidFrom, p1.ValidTo, p1.StartDay, p1.EndDay, p1.StartTime, p1.EndTime,
                        p2.ValidFrom, p2.ValidTo, p2.StartDay, p2.EndDay, p2.StartTime, p2.EndTime))
                    {
                        throw new UserException("Overlapping dynamic prices are not allowed. Check validity dates, days of the week, and time ranges.");
                    }
                }
            }
        }

        private void ValidatePeriod(TimeOnly start, TimeOnly end, DateOnly validFrom, DateOnly? validTo, decimal? price = null)
        {
            if (start >= end)
                throw new UserException("Start time must be before end time.");

            if (validTo.HasValue && validFrom > validTo.Value)
                throw new UserException("From date must be before or equal to To date.");

            if (price.HasValue && price.Value <= 0)
                throw new UserException("Price per hour must be a positive value.");
        }

        private void EnsureNoOverlaps(IEnumerable<WorkingHours> existing, DayOfWeek startDay, DayOfWeek endDay, TimeOnly start, TimeOnly end, DateOnly validFrom, DateOnly? validTo, int? currentRecordId)
        {
            foreach (var record in existing)
            {
                if (currentRecordId.HasValue && record.Id == currentRecordId.Value)
                    continue;

                if (ArePeriodsConflicting(
                    validFrom, validTo, startDay, endDay, start, end,
                    record.ValidFrom, record.ValidTo, record.StartDay, record.EndDay, record.OpeningHours, record.CloseingHours))
                {
                    throw new UserException("Overlapping working-hour records are not allowed for the same sport center.");
                }
            }
        }

        private void EnsureNoOverlaps(IEnumerable<FacilityDynamicPrice> existing, DayOfWeek startDay, DayOfWeek endDay, TimeOnly start, TimeOnly end, DateOnly validFrom, DateOnly? validTo, int? currentRecordId)
        {
            foreach (var record in existing)
            {
                if (currentRecordId.HasValue && record.Id == currentRecordId.Value)
                    continue;

                if (ArePeriodsConflicting(
                    validFrom, validTo, startDay, endDay, start, end,
                    record.ValidFrom, record.ValidTo, record.StartDay, record.EndDay, record.StartTime, record.EndTime))
                {
                    throw new UserException("Overlapping dynamic prices are not allowed. Check validity dates, days of the week, and time ranges.");
                }
            }
        }

        private bool ArePeriodsConflicting(
            DateOnly from1, DateOnly? to1, DayOfWeek startDay1, DayOfWeek endDay1, TimeOnly open1, TimeOnly close1,
            DateOnly from2, DateOnly? to2, DayOfWeek startDay2, DayOfWeek endDay2, TimeOnly open2, TimeOnly close2)
        {
            bool datesOverlap = true;
            if (to1.HasValue && to1.Value < from2) datesOverlap = false;
            if (to2.HasValue && to2.Value < from1) datesOverlap = false;

            if (!datesOverlap) return false;

            var days1 = GetDaysInRange(startDay1, endDay1);
            var days2 = GetDaysInRange(startDay2, endDay2);
            bool daysOverlap = days1.Intersect(days2).Any();

            if (!daysOverlap) return false;

            bool timesOverlap = true;
            if (open2 >= close1) timesOverlap = false;
            if (close2 <= open1) timesOverlap = false;

            return timesOverlap;
        }

        private void EnsureWithinWorkingHours(IEnumerable<WorkingHours> workingHours, DayOfWeek startDay, DayOfWeek endDay, TimeOnly startTime, TimeOnly endTime, DateOnly validFrom, DateOnly? validTo)
        {
            if (!workingHours.Any())
                throw new UserException("Sport center does not have configured working hours.");

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
                    continue;

                if (interval.StartDay > cursorDay)
                    return false;

                if (interval.EndDay >= requiredEndDay)
                    return true;

                if (interval.EndDay >= maxDayNumber)
                    return true;

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
