using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.SearchObjects
{
    public class FacilityReviewSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? FacilityId { get; set; }
        public int? MinRating { get; set; }
        public int? MaxRating { get; set; }
        public DateTime? RatingDateFrom { get; set; }
        public DateTime? RatingDateTo { get; set; }
    }
}
