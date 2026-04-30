using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Enums;

namespace TerminBA.Models.Model
{
    public class AdminDashboardResponse
    {
        public int AppUserCount { get; set; }
        public int AppReservationCount { get; set; }
        public int AppSportCenterCount { get; set; }
        public Dictionary<int,int>? UserCountByMonth { get; set; }
        public Dictionary<int, int>? ReservationCountByMonth { get; set; }
    }
}
