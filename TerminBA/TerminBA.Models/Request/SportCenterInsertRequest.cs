using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;

namespace TerminBA.Models.Request
{
    public class SportCenterInsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string? Username { get; set; }

        [Required]
        [Phone]
        public string? PhoneNumber { get; set; }

        [Required]
        public int CityId { get; set; }

        [Required]
        public required string Address { get; set; }

        [Required]
        public bool IsEquipmentProvided { get; set; }

        [MaxLength(180)]
        public string? Description { get; set; }

        [Required]
        public int RoleId { get; set; }

        [Required]
        [MinLength(1, ErrorMessage = "At least one sport must be selected.")]
        public List<int>? SportIds { get; set; }

        [Required]
        [MinLength(1, ErrorMessage = "At least one amenity must be selected.")]
        public List<int>? AmenityIds { get; set; }

        [Required]
        [MinLength(1, ErrorMessage = "Working hours are required.")]
        public List<WorkingHoursInsertRequest>? WorkingHours { get; set; }
    }
}



