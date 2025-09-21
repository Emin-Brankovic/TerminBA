using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Request
{
    public class UserReviewUpdateRequest
    {
        [Range(1, 5)]
        public int RatingNumber { get; set; }

        [Required]
        public DateOnly RatingDate { get; set; }

        [MaxLength(180)]
        public string? Comment { get; set; }

        public int? ReviewerId { get; set; }

        public int? ReviewedId { get; set; }
    }
}




