using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class PostResponse
    {
        public int Id { get; set; }

        public string? SkillLevel { get; set; }

        public string? Text { get; set; }

        public int ReservationId { get; set; }

        public ReservationResponse? Reservation { get; set; }
    }
}



