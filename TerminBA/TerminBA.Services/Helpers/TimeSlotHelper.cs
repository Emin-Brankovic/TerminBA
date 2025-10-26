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
            var radnoVrijeme = facility.SportCenter.WorkingHours.ToList();


            var trenutno = radnoVrijeme.FirstOrDefault(rv => reservationDayOfWeek >= rv.StartDay
            || reservationDayOfWeek <= rv.EndDay);

            TimeSpan opening = trenutno.OpeningHours.ToTimeSpan();
            TimeSpan closing = trenutno.CloseingHours.ToTimeSpan();
            TimeSpan duration = facility.Duration;

            var allSlots = new List<(TimeSpan Start, TimeSpan End)>();

            for (TimeSpan start = opening; start + duration <= closing; start += duration)
            {
                allSlots.Add((start, start + duration));
            }

            return allSlots;
        }
    }
}
