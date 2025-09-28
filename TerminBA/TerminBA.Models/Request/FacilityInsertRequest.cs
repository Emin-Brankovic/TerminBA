using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;

namespace TerminBA.Models.Request
{
    public class FacilityInsertRequest
    {
        [Required]
        [MaxLength(100)]
        public required string Name { get; set; }

        [Required]
        public int MaxCapacity { get; set; }

        [Required]
        public double PricePerHour { get; set; }

        [Required]
        public bool IsIndoor { get; set; }

        [Required]
        public TimeSpan Duration { get; set; }

        [Required]
        public int SportCenterId { get; set; }

        [Required]
        public int TurfTypeId { get; set; }

        public List<int> AvailableSportsIds { get; set; } = new List<int>();
    }
}



