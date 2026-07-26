namespace TerminBA.Services.Recommender
{
    public class RecommendationResult
    {
        public int FacilityId { get; set; }

        public string FacilityName { get; set; } = string.Empty;

        public string SportCenterName { get; set; } = string.Empty;

        public DateTime StartTime { get; set; }

        public DateTime EndTime { get; set; }

        public decimal Price { get; set; }

        public float Score { get; set; }

        public List<string> Reasons { get; set; } = new();

        public bool IsPersonalized { get; set; } = true;
    }
}
