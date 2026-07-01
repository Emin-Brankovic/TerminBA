namespace TerminBA.Models.Model
{
    public class CancellationResponse
    {
        public string ReservationState { get; set; } = string.Empty;
        public bool RefundIssued { get; set; }
        public string? RefundStatus { get; set; }
        public decimal? RefundAmount { get; set; }
    }
}
