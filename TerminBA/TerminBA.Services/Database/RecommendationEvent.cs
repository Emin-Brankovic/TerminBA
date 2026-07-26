using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TerminBA.Services.Database
{
    public class RecommendationEvent
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        public int FacilityId { get; set; }

        [Required]
        public DateTime CandidateStart { get; set; }

        [Required]
        public DateTime CandidateEnd { get; set; }

        public float Score { get; set; }

        [MaxLength(2000)]
        public string? ExplanationJson { get; set; }

        public bool WasClicked { get; set; }

        public bool WasBooked { get; set; }

        [Required]
        public DateTime ShownAt { get; set; }

        [ForeignKey(nameof(UserId))]
        public User? User { get; set; }

        [ForeignKey(nameof(FacilityId))]
        public Facility? Facility { get; set; }
    }
}
