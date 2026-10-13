namespace TerminBA.Services.Recommender
{
    public class TimeSlotCandidate
    {
        public int FacilityId { get; set; }
        public string FacilityName { get; set; } = string.Empty;
        public int SportCenterId { get; set; }
        public string SportCenterName { get; set; } = string.Empty;
        public int? CityId { get; set; }
        public bool IsIndoor { get; set; }
        public int TurfTypeId { get; set; }
        public List<int> SportIds { get; set; } = new();
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public decimal Price { get; set; }
    }
}
