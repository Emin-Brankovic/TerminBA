using System;

namespace TerminBA.Models.Model
{
    public class NotificationResponse
    {
        public int Id { get; set; }
        public int PostOwnerId { get; set; }
        public int ReservationId { get; set; }
        public ReservationResponse? Reservation { get; set; }
        public string RequesterName { get; set; } = string.Empty;
        public string FacilityName { get; set; } = string.Empty;
        public DateTime Date { get; set; }
        public bool IsSeen { get; set; }
        public string? Reason { get; set; }
        public string Type { get; set; } = string.Empty; // "Cancelation" or "Update"
    }
}
