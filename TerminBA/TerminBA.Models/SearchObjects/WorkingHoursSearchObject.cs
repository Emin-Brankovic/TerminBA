using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Enums;

namespace TerminBA.Models.SearchObjects
{
    public class WorkingHoursSearchObject : BaseSearchObject
    {
        public int? SportCenterId { get; set; }
        //public DayOfWeekEnum? StartDay { get; set; }
        //public DayOfWeekEnum? EndDay { get; set; }
        //public DateTime? ValidFrom { get; set; }
        //public DateTime? ValidTo { get; set; }
    }
}
