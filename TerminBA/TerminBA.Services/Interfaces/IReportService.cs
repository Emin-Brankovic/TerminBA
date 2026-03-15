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
    }
}
