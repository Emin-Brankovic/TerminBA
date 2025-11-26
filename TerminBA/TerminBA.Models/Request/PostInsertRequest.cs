using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Request
{
    public class PostInsertRequest
    {
        [Required]
        public string? SkillLevel { get; set; }

        [MaxLength(100)]
        public string? Text { get; set; }

        [Required]
        public int ReservationId { get; set; }

        [Required]
        public int NumberOfPlayersWanted { get; set; }

    }
}




