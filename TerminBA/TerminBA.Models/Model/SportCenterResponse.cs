using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class SportCenterResponse
    {
        public int Id { get; set; }

        public string? Name { get; set; }

        public string? PhoneNumber { get; set; }

        public int CityId { get; set; }

        public CityResponse? City { get; set; }

        public string? Address { get; set; }

        public bool IsEquipmentProvided { get; set; }

        public string? Description { get; set; }

        public DateTime CreatedAt { get; set; }

        public int RoleId { get; set; }
        public RoleResponse? Role { get; set; }

        public ICollection<WorkingHoursResponse> WorkingHours { get; set; } = new List<WorkingHoursResponse>();

        public ICollection<SportResponse> AvailableSports { get; set; } = new List<SportResponse>();

        public ICollection<AmenityResponse> AvailableAmenities { get; set; } = new List<AmenityResponse>();

        //public ICollection<FacilityResponse> Facilities { get; set; } = new List<FacilityResponse>();
    }
}



