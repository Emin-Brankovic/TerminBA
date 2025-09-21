using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class UserReviewResponse
    {
        public int Id { get; set; }

        public int RatingNumber { get; set; }

        public DateOnly RatingDate { get; set; }

        public string? Comment { get; set; }

        public int? ReviewerId { get; set; }
        public UserResponse? Reviewer { get; set; }

        public int? ReviewedId { get; set; }
        public UserResponse? Reviewed { get; set; }
    }
}



