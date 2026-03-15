using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using TerminBA.Models.Enums;
using TerminBA.Models.Model;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class ReportService : IReportService
    {
        private readonly TerminBaContext _context;

        public ReportService(TerminBaContext context)
        {
            this._context = context;
        }
        public async Task<DashboardResponse> GetDashboard(int year)
        {
            var userCount = await _context.Users.CountAsync();
            var sportCenterCount = await _context.SportCenters.CountAsync();
            var reservationCount = await _context.Reservations.CountAsync();

            var userCountsByMonth = await _context.Users
                .Where(u => u.CreatedAt.Year == year)
                .GroupBy(u => u.CreatedAt.Month)
                .Select(g => new 
                {
                    Month = g.Key,
                    UserCount = g.Count()
                })
                .ToDictionaryAsync(x=>x.Month,x=>x.UserCount);


            var reservationCountByMonth = await _context.Reservations
                .Where(u => u.ReservationDate.Year == year)
                .GroupBy(u => u.ReservationDate.Month)
                .Select(g => new
                {
                    Month = g.Key,
                    UserCount = g.Count()
                })
                .ToDictionaryAsync(x => x.Month, x => x.UserCount);


            var response = new DashboardResponse
            {
                AppUserCount = userCount,
                AppReservationCount = reservationCount,
                AppSportCenterCount = sportCenterCount,
                UserCountByMonth = userCountsByMonth,
                ReservationCountByMonth = reservationCountByMonth,
            };


           return response;


        }
    }
}
