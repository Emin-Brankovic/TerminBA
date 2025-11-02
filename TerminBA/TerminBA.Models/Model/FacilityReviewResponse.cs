using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class FacilityReviewResponse
    {
        public int Id { get; set; }

        public int RatingNumber { get; set; }

        public DateOnly RatingDate { get; set; }

        public string? Comment { get; set; }

        public int? UserId { get; set; }

        public UserResponse? User { get; set; }

        public int? FacilityId { get; set; }

        public FacilityResponse? Facility { get; set; }

        //public ICollection<FacilityReviewResponse> FacilityReviews { get; set; } = new List<FacilityReviewResponse>();
    }
}



