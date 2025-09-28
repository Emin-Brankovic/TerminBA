using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.SearchObjects
{
    public class ReservationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? FacilityId { get; set; }
        public DateTime? ReservationDate { get; set; }
        public string? Status { get; set; }
        public int? ChosenSportId { get; set; }
    }
}

