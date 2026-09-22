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
        public int ReservationId { get; set; }
    }
}
