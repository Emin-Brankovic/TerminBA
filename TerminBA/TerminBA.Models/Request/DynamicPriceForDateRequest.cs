using System.ComponentModel.DataAnnotations;

namespace TerminBA.Models.Request
{
    public class DynamicPriceForDateRequest
    {
        [Required]
        public int FacilityId { get; set; }

        [Required]
        public DateOnly ReservationDate { get; set; }

        [Required]
        public TimeOnly StartTime { get; set; }

        [Required]
        public TimeOnly EndTime { get; set; }
    }
}