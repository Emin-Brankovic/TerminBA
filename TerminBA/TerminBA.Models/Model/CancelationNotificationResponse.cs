using System;

namespace TerminBA.Models.Model
{
    public class CancelationNotificationResponse
    {
        public int Id { get; set; }
        public int PostOwnerId { get; set; }
        public int ReservationId { get; set; }
        public string RequesterName { get; set; } = string.Empty;
        public string FacilityName { get; set; } = string.Empty;
        public DateTime DateCancelled { get; set; }
        public bool IsSeen { get; set; }
        public ReservationResponse? Reservation { get; set; }
    }
}
