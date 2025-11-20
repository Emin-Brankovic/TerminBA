using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.SearchObjects
{
    public class FacilityDynamicPriceSearchObject : BaseSearchObject
    {
        public int? FacilityId { get; set; }
        public DayOfWeek? StartDay { get; set; }
        public DayOfWeek? EndDay { get; set; }
        public bool? IsActive { get; set; }
        public DateOnly? ValidFrom { get; set; }
        public DateOnly? ValidTo { get; set; }
    }
}

