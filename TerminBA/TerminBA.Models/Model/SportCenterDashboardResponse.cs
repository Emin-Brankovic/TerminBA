using System.Collections.Generic;

namespace TerminBA.Models.Model
{
    public class SportCenterDashboardResponse
    {
        public decimal TodayRevenue { get; set; }
        public decimal WeeklyRevenue { get; set; }
        public int ReservationsToday { get; set; }
        public int ActiveFacilities { get; set; }
        public int NewReviews7d { get; set; }
        public decimal AverageRating { get; set; }
        public int ReviewsIn7d { get; set; }
        public int ReviewsIn30d { get; set; }
        public Dictionary<string, int> ReservationsByWeekday { get; set; } = new();
        public Dictionary<string, int> ReservationsBySport { get; set; } = new();
        public Dictionary<string, int> ReservationsByFacility { get; set; } = new();
        public List<DashboardUpcomingReservationResponse> UpcomingReservations { get; set; } = new();
        public List<DashboardLowRatedReviewResponse> LowestRatedReviews { get; set; } = new();
    }

    public class DashboardUpcomingReservationResponse
    {
        public string Slot { get; set; } = string.Empty;
        public string FacilityName { get; set; } = string.Empty;
        public string BookedBy { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
    }

    public class DashboardLowRatedReviewResponse
    {
        public string FacilityName { get; set; } = string.Empty;
        public int Rating { get; set; }
        public string Comment { get; set; } = string.Empty;
    }
}
