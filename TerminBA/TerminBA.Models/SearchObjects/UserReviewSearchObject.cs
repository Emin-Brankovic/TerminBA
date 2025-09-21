using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.SearchObjects
{
    public class UserReviewSearchObject : BaseSearchObject
    {
        public int? ReviewerId { get; set; }
        public int? ReviewedId { get; set; }
        public int? MinRating { get; set; }
        public int? MaxRating { get; set; }
        public DateTime? RatingDateFrom { get; set; }
        public DateTime? RatingDateTo { get; set; }
    }
}
