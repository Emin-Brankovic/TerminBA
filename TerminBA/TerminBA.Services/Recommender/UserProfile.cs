namespace TerminBA.Services.Recommender
{
    public class UserProfile
    {
        public int UserId { get; set; }

        public int? MostBookedSportId { get; set; }

        public decimal AveragePaidPrice { get; set; }

        public Dictionary<int, int> BookingCountPerFacility { get; set; } = new();

        public Dictionary<int, float> UserRatingPerFacility { get; set; } = new();

        public Dictionary<int, float> OverallRatingPerFacility { get; set; } = new();
    }
}
