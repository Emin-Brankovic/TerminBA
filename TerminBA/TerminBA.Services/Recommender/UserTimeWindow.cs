namespace TerminBA.Services.Recommender
{
    public class UserTimeWindow
    {
        public List<DayOfWeek> PreferredDays { get; set; } = new();

        public Dictionary<DayOfWeek, float> DayFrequency { get; set; } = new();

        public TimeSpan PreferredStart { get; set; }

        public TimeSpan PreferredEnd { get; set; }

        public TimeSpan MedianStart { get; set; }

        public List<RoutineSlot> RoutineSlots { get; set; } = new();

        public bool HasEnoughHistory { get; set; }
    }

    public class RoutineSlot
    {
        public DayOfWeek Day { get; set; }

        public TimeSpan Start { get; set; }

        public int Occurrences { get; set; }
    }
}
