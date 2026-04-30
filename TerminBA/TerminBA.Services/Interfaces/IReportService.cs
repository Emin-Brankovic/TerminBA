using MimeKit.Tnef;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;

namespace TerminBA.Services.Interfaces
{
    public interface IReportService
    {
        public Task<AdminDashboardResponse> GetDashboard(int year);
        public byte[] GetAdminReport(int totalUsers,int totalSportCenters, int totalReservations, int selectedYear, byte[] imageBytes);
        public byte[] SportCenterCredentialsReport(string username, string password);
        public Task<SportCenterReservationStatsResponse> SportCenterReservationStats(DateOnly? fromDate = null, DateOnly? toDate = null);
        public byte[] SportCenterReservationStatsReport(SportCenterReservationStatsReportRequest request);
        public Task<FinanceSummaryResponse> SportCenterFinanceSummary(int year, int month);
        public Task<SportCenterDashboardResponse> SportCenterDashboard();

    }
}
