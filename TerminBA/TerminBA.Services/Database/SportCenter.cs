using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class SportCenter : AccountBase
    {
        //public decimal Langitude { get; set; }
        //public decimal Latitude { get; set; }

        [Required]
        public string? Address { get; set; }

        [Required]
        public bool IsEquipmentProvided { get; set; }

        [MaxLength(180)]
        public string? Description { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<WorkingHours> WorkingHours { get; set; } = new List<WorkingHours>();

        public ICollection<Sport> AvailableSports { get; set; } = new List<Sport>();

        public ICollection<Amenity> AvailableAmenities { get; set; } = new List<Amenity>();

        public ICollection<Facility> Facilities { get; set; } = new List<Facility>();

    }
}
