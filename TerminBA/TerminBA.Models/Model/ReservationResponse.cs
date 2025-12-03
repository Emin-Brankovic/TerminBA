using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class ReservationResponse
    {
        public int Id { get; set; }

        public int? UserId { get; set; }

        public UserResponse? User { get; set; }

        public int? FacilityId { get; set; }

        public FacilityResponse? Facility { get; set; }

        public DateOnly ReservationDate { get; set; }

        public TimeOnly StartTime { get; set; }

        public TimeOnly EndTime { get; set; }

        public string? Status { get; set; }

        public decimal Price { get; set; }

        //public ICollection<PostResponse> Posts { get; set; } = new List<PostResponse>();

        public int? ChosenSportId { get; set; }

        public SportResponse? ChosenSport { get; set; }
    }
}



