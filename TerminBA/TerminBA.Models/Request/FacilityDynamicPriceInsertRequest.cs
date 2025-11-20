using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Request
{
    public class FacilityDynamicPriceInsertRequest
    {
        [Required]
        public int FacilityId { get; set; }

        [Required]
        public DayOfWeek StartDay { get; set; }

        [Required]
        public DayOfWeek EndDay { get; set; }

        [Required]
        public TimeOnly StartTime { get; set; }

        [Required]
        public TimeOnly EndTime { get; set; }

        [Required]
        [Range(0, double.MaxValue, ErrorMessage = "Price per hour must be a positive value.")]
        public decimal PricePerHour { get; set; }

        [Required]
        public DateOnly ValidFrom { get; set; }

        public DateOnly? ValidTo { get; set; }
    }
}

