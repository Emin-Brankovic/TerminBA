using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{

    public class FacilityReview
    {
        [Key]
        public int Id { get; set; }

        [Range (1,5)]
        public int RatingNumber { get; set; }

        [Required]
        public DateOnly RatingDate { get; set; }

        [MaxLength (180)]
        public string? Comment { get; set; }

        [ForeignKey (nameof(User))]
        public int? UserId { get; set; }
        public User? User{ get; set; }

        [ForeignKey(nameof(Facility))]
        public int? FacilityId { get; set; }
        public Facility? Facility { get; set; }
     
       // public ICollection<FacilityReview> FacilityReviews { get; set; } = new List<FacilityReview>();
    }
}
