using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class FacilityDynamicPriceResponse
    {
        public int Id { get; set; }

        public int FacilityId { get; set; }

        //public FacilityResponse? Facility { get; set; }

        public string? FacilityName { get; set; }

        public DayOfWeek StartDay { get; set; }

        public DayOfWeek EndDay { get; set; }

        public TimeOnly StartTime { get; set; }

        public TimeOnly EndTime { get; set; }

        public decimal PricePerHour { get; set; }

        public bool IsActive { get; set; }

        public DateOnly ValidFrom { get; set; }

        public DateOnly? ValidTo { get; set; }
    }
}

