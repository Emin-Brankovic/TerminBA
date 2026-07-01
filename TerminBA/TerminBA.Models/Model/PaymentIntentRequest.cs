using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class PaymentIntentRequest
    {
        [Required]
        [Range(50, long.MaxValue, ErrorMessage = "Amount must be at least 50 (smallest currency units).")]
        public long Amount { get; set; }
        public string Currency { get; set; } = "bam";
        public int? FacilityId { get; set; }
        public int? UserId { get; set; }

        [Required]
        public int ReservationId { get; set; }
    }
}
