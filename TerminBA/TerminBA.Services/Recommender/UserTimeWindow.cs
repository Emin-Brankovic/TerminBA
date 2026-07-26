namespace TerminBA.Services.Recommender
{
    public class UserTimeWindow
    {
        public List<DayOfWeek> PreferredDays { get; set; } = new();

        public TimeSpan PreferredStart { get; set; }

        public TimeSpan PreferredEnd { get; set; }

        public TimeSpan MedianStart { get; set; }

        public bool HasEnoughHistory { get; set; }
    }
}
