using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;

namespace TerminBA.Services.Interfaces
{
    public interface IReportService
    {
        public Task<DashboardResponse> GetDashboard(int year);
        public byte[] GetAdminReport(int totalUsers,int totalSportCenters, int totalReservations, int selectedYear, byte[] imageBytes);
        public byte[] SportCenterCredentialsReport(string username, string password);

    }
}
