using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class UserReview
    {
        [Key]
        public int Id { get; set; }

        [Range(1, 5)]
        public int RatingNumber { get; set; }

        [Required]
        public DateOnly RatingDate { get; set; }

        [MaxLength(180)]
        public string? Comment { get; set; }

        [ForeignKey(nameof(User))]
        public int? ReviewerId { get; set; }
        public User? Reviewer { get; set; }

        [ForeignKey(nameof(User))]
        public int? ReviewedId { get; set; }
        public User? Reviewed { get; set; }
    }
}
