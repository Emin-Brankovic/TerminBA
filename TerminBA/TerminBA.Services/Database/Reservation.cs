using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class Reservation
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(User))]
        public int? UserId { get; set; }
        public User? User { get; set; }


        [ForeignKey(nameof(Facility))]
        public int? FacilityId { get; set; }
        public Facility? Facility { get; set; }

        [Required]
        public DateOnly ReservationDate { get; set; }

        [Required]
        public TimeOnly StartTime { get; set; }

        [Required]
        public TimeOnly EndTime { get; set; }

        [MaxLength(100)]
        public string? Status { get; set; }

        [Required]
        [Column(TypeName = "decimal(10,2)")]
        public decimal Price { get; set; }

        public ICollection<Post>? Posts { get; set; } = new List<Post>();

        [ForeignKey(nameof(ChosenSport))]
        public int? ChosenSportId { get; set; }
        public Sport? ChosenSport { get; set; }

    }
}
