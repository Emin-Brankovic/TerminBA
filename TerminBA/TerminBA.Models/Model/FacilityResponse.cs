using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class FacilityResponse
    {
        public int Id { get; set; }

        public string? Name { get; set; }

        public int MaxCapacity { get; set; }

        public double PricePerHour { get; set; }

        public bool IsIndoor { get; set; }

        public TimeSpan Duration { get; set; }

        public int SportCenterId { get; set; }

        public SportCenterResponse? SportCenter { get; set; }

        public int TurfTypeId { get; set; }

        public TurfTypeResponse? TurfType { get; set; }

        public ICollection<SportResponse> AvailableSports { get; set; } = new List<SportResponse>();

        public ICollection<FacilityReviewResponse> ReviewsReceived { get; set; } = new List<FacilityReviewResponse>();

        public ICollection<ReservationResponse> Reservations { get; set; } = new List<ReservationResponse>();
    }
}



