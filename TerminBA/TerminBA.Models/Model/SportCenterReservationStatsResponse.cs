using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class SportCenterReservationStatsResponse
    {
        public Dictionary<string, int>? ReservationCountBySport { get; set; }
        public Dictionary<string, int>? ReservationCountByWeekDay { get; set; }
        public Dictionary<string, int>? ReservationCountByFacility { get; set; }

    }
}
