namespace TerminBA.Services.Recommender
{
    public class UserProfile
    {
        public int UserId { get; set; }

        public int? HomeCityId { get; set; }

        public int? MostBookedSportId { get; set; }

        public Dictionary<int, float> SportPreference { get; set; } = new();

        public Dictionary<int, float> SportCenterAffinity { get; set; } = new();

        public Dictionary<int, float> CityPreference { get; set; } = new();

        public Dictionary<int, float> TurfTypePreference { get; set; } = new();

        public float IndoorPreference { get; set; } = 0.5f;

        public decimal AveragePaidPrice { get; set; }

        public Dictionary<int, int> BookingCountPerFacility { get; set; } = new();

        public HashSet<int> BookedSportCenterIds { get; set; } = new();

        public Dictionary<int, float> UserRatingPerFacility { get; set; } = new();

        public Dictionary<int, float> OverallRatingPerFacility { get; set; } = new();

        public Dictionary<int, int> ReviewCountPerFacility { get; set; } = new();

        public float GlobalAverageRating { get; set; } = 3.5f;
    }
}
