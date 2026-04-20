using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;
using TerminBA.Services.Database;

namespace TerminBA.Services.Helpers
{
    public static class DynamicPriceHelper
    {
        public static decimal GetExpectedPrice(Facility facility, DateOnly reservationDate, TimeOnly startTime, TimeOnly endTime)
        {
            var durationHours = (decimal)facility.Duration.TotalHours;

            if (!facility.IsDynamicPricing)
            {
                if (!facility.StaticPrice.HasValue)
                    throw new UserException("Static price is not configured for this facility.");

                return facility.StaticPrice.Value;
            }

            var dynamicPrice = facility.DynamicPrices
                .FirstOrDefault(dp =>
                    TimeSlotHelper.IsInDayRange(reservationDate.DayOfWeek, dp.StartDay, dp.EndDay)
                    && TimeSlotHelper.IsWithinValidityPeriod(reservationDate, dp.ValidFrom, dp.ValidTo)
                    && dp.StartTime <= startTime
                    && dp.EndTime >= endTime)
                ?? throw new UserException("No price is found for selected time and date");

            return dynamicPrice.PricePerHour;
        }
    }
}
