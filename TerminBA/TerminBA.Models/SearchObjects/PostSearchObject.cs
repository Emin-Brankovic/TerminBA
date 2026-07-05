using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.SearchObjects
{
    public class PostSearchObject : BaseSearchObject
    {
        public string? SkillLevel { get; set; }
        public int? SportId { get; set; }
        public DateOnly? ReservationDate { get; set; }
        public int? CityId { get; set; }
        public int? TurfTypeId { get; set; }
        /// <summary>
        /// Filter by post state, e.g. "PlayerSearchPostState" for the public feed.
        /// </summary>
        public string? PostState { get; set; }
        /// <summary>
        /// Filter to only posts where the reservation was created by this user.
        /// </summary>
        public int? UserId { get; set; }
    }
}






