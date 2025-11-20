using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class Facility
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string? Name { get; set; }

        [Required]
        public int MaxCapacity { get; set; }

        [Required]
        public bool IsDynamicPricing { get; set; }

        [Column(TypeName = "decimal(10,2)")]
        public decimal? StaticPrice { get; set; } // is null when there is dynamic pricing 

        [Required]
        public bool IsIndoor { get; set; }

        [Required]
        public TimeSpan Duration { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; }

        [ForeignKey(nameof(SportCenter))]
        public int SportCenterId { get; set; }
        public SportCenter? SportCenter { get; set; }

        [ForeignKey(nameof(TurfType))]
        public int TurfTypeId { get; set; }
        public TurfType? TurfType { get; set; }

        public ICollection<Sport> AvailableSports { get; set; } = new List<Sport>();

        public ICollection<FacilityReview> ReviewsReceived { get; set; } = new List<FacilityReview>();

        public ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

        public ICollection<FacilityDynamicPrice> DynamicPrices { get; set; } = new List<FacilityDynamicPrice>();
    }
}
