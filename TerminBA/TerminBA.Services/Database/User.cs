using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class User : AccountBase
    {
        [Required]
        [MaxLength(50)]
        [MinLength(2)]
        public string? FirstName { get; set; }

        [Required]
        [MaxLength(50)]
        [MinLength(2)]
        public string? LastName { get; set; }

        [Range(14, 100, ErrorMessage = "Age must be between 14 and 100")]
        public int Age { get; set; }

        [Required]
        [EmailAddress]
        public string? Email { get; set; }

        [Required]
        public DateOnly BirthDate { get; set; }

        public bool IsActive { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime UpdatedAt { get; set; }

        public ICollection<UserReview> UserReviewsGiven { get; set; } = new List<UserReview>();
        public ICollection<UserReview> ReviewsReceived { get; set; } = new List<UserReview>();
        public ICollection<FacilityReview> FacilityReviewsGiven { get; set; } = new List<FacilityReview>();
        public ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();
    }
}
