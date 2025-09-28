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
        public string? Name { get; set; }

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
        public List<int>? SportIds { get; set; }

        [Required]
        public List<int>? AmenityIds { get; set; }

        [Required]
        public List<WorkingHoursInsertRequest>? WorkingHours { get; set; }
    }
}



