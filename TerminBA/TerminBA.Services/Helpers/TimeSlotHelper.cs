using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Request;
using TerminBA.Services.Database;

namespace TerminBA.Services.Helpers
{
    public static class TimeSlotHelper 
    {
        public static async Task<List<(TimeSpan Start, TimeSpan End)>> GenerateTimeSlots(int? facilityId,DateOnly pickedDate,TerminBaContext _context)
        {
            var facility = await _context.Facilities
                .Include(f => f.SportCenter)
                .ThenInclude(sc => sc.WorkingHours)
                .FirstOrDefaultAsync(f => f.Id == facilityId);

            if (facility == null)
                throw new Exception("Facility was not found");

            var reservationDayOfWeek = pickedDate.DayOfWeek;
            var workingHours = facility.SportCenter.WorkingHours.ToList();


            var currentWorkingHours = workingHours.FirstOrDefault(rv => 
            IsInDayRange(reservationDayOfWeek, rv.StartDay, rv.EndDay) 
            && rv.ValidFrom<=pickedDate 
            && (rv.ValidTo == null || rv.ValidTo >= pickedDate));

            TimeSpan opening = currentWorkingHours.OpeningHours.ToTimeSpan();
            TimeSpan closing = currentWorkingHours.CloseingHours.ToTimeSpan();
            TimeSpan duration = facility.Duration;

            var allSlots = new List<(TimeSpan Start, TimeSpan End)>();

            for (TimeSpan start = opening; start + duration <= closing; start += duration)
            {
                allSlots.Add((start, start + duration));
            }
            
            return allSlots;
        }

        public static bool IsInDayRange(DayOfWeek targetDay, DayOfWeek startDay, DayOfWeek endDay)
        {
            if (startDay <= endDay)
                return targetDay >= startDay && targetDay <= endDay;
            else
                return targetDay >= startDay || targetDay <= endDay;
        }
    }
}
