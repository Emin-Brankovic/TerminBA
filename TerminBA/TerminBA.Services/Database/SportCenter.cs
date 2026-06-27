using Microsoft.EntityFrameworkCore;
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

        [Required]
        public string? Address { get; set; }

        [Required]
        public bool IsEquipmentProvided { get; set; }

        [EmailAddress]
        [MaxLength(150)]
        public string? ContactEmail { get; set; }

        [MaxLength(180)]
        public string? Description { get; set; }
        [Precision(13, 10)]
        public decimal? Longitude { get; set; }
        [Precision(12, 10)]
        public decimal? Latitude { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }


        public ICollection<WorkingHours> WorkingHours { get; set; } = new List<WorkingHours>();

        public ICollection<Sport> AvailableSports { get; set; } = new List<Sport>();

        public ICollection<Amenity> AvailableAmenities { get; set; } = new List<Amenity>();

        public ICollection<Facility> Facilities { get; set; } = new List<Facility>();

        public ICollection<SportCenterPhoto> Photos { get; set; } = new List<SportCenterPhoto>();

        public ICollection<FavoriteSportCenter> FavoritedByUsers { get; set; } = new List<FavoriteSportCenter>();

    }
}
