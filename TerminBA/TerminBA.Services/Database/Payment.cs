using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using TerminBA.Services.Enums;

namespace TerminBA.Services.Database
{
    public class Payment
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(Reservation))]
        public int ReservationId { get; set; }
        public Reservation Reservation { get; set; } = null!;

        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public User User { get; set; } = null!;

        [Required]
        [MaxLength(50)]
        public string Provider { get; set; } = "stripe";

        [MaxLength(255)]
        public string? StripePaymentIntentId { get; set; }

        [MaxLength(255)]
        public string? StripeChargeId { get; set; }

        [MaxLength(255)]
        public string? StripeRefundId { get; set; }

        [Required]
        [Column(TypeName = "decimal(10,2)")]
        public decimal Amount { get; set; }

        [Required]
        [MaxLength(10)]
        public string Currency { get; set; } = "bam";

        [Required]
        public PaymentStatus Status { get; set; } = PaymentStatus.RequiresPayment;

        [Column(TypeName = "decimal(10,2)")]
        public decimal? RefundAmount { get; set; }

        public DateTime? PaidAt { get; set; }
        public DateTime? RefundRequestedAt { get; set; }
        public DateTime? RefundedAt { get; set; }

        public string? Metadata { get; set; }

        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
