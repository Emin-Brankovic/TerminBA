using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TerminBA.Services.Database
{
    public class CancelationNotification
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [ForeignKey(nameof(PostOwner))]
        public int PostOwnerId { get; set; }
        public User? PostOwner { get; set; }

        [Required]
        [ForeignKey(nameof(Reservation))]
        public int ReservationId { get; set; }
        public Reservation? Reservation { get; set; }

        [Required]
        [MaxLength(100)]
        public string RequesterName { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string FacilityName { get; set; } = string.Empty;

        [Required]
        public DateTime DateCancelled { get; set; } = DateTime.Now;

        public bool IsSeen { get; set; } = false;
    }
}
