using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Request
{
    public class ReservationInsertRequest
    {
        public int? UserId { get; set; }

        public int? FacilityId { get; set; }

        [Required]
        public DateOnly ReservationDate { get; set; }

        [Required]
        public TimeOnly StartTime { get; set; }

        [Required]
        public TimeOnly EndTime { get; set; }

        [Required]
        [MaxLength(100)]
        public string? Status { get; set; }

        public int? ChosenSportId { get; set; }
    }
}



