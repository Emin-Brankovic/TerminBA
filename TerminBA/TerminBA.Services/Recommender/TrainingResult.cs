namespace TerminBA.Services.Recommender
{
    public class TrainingResult
    {
        public bool Success { get; set; }
        public double Accuracy { get; set; }
        public double AreaUnderRocCurve { get; set; }
        public double F1Score { get; set; }
        public int TrainingRowCount { get; set; }
        public DateTime TrainedAt { get; set; }
        public string? ErrorMessage { get; set; }
    }
}
