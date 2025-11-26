using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class Post
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string? SkillLevel { get; set; }

        [Required]
        public int NumberOfPlayersWanted { get; set; }

        [Required]
        public int NumberOfPlayersFound { get; set; }

        [MaxLength(100)]
        public string? Text { get; set; }

        [Required]
        [ForeignKey(nameof(Reservation))]
        public int ReservationId { get; set; }
        public Reservation? Reservation { get; set; } // Veže se za usera koji je napravio rezervaciju

        [MaxLength(1000)]
        public string PostState { get; set; } = string.Empty;

    }
}
