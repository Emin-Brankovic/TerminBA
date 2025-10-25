using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Request
{
    public class FacilityUpdateRequest
    {
        [Required]
        [MaxLength(100)]
        public required string Name { get; set; }

        [Required]
        [Range(0, 80)]
        public int MaxCapacity { get; set; }

        [Required]
        [Range(0, 300)]
        public double PricePerHour { get; set; }

        [Required]
        public bool IsIndoor { get; set; }

        [Required]
        public TimeSpan Duration { get; set; }

        [Required]
        public int SportCenterId { get; set; }

        [Required]
        public int TurfTypeId { get; set; }

        [Required]
        [MinLength(1, ErrorMessage = "At least one sport must be selected.")]
        public List<int> AvailableSportsIds { get; set; } = new List<int>();
    }
}



