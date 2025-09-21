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
    public class SportCenter
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string? Name { get; set; }

        [Required]
        [Phone(ErrorMessage = "Not valid phone number format")]
        public string? PhoneNumber { get; set; }

        [ForeignKey(nameof(City))]
        [Required]
        public int CityId { get; set; }
        public City? City { get; set; }

        //public decimal Langitude { get; set; }
        //public decimal Latitude { get; set; }

        [Required]
        public string? Address { get; set; }

        [Url(ErrorMessage = "Not a valid url")]
        public string? InstagramAccount { get; set; }

        [Required]
        public string PasswordSalt { get; set; } = string.Empty;

        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        [Required]
        public bool IsEquipmentProvided { get; set; }

        [MaxLength(180)]
        public string? Description { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(Role))]
        [Required]
        public int RoleId { get; set; }
        public Role? Role { get; set; }

        public ICollection<WorkingHours> WorkingHours { get; set; } = new List<WorkingHours>();

        public ICollection<Sport> AvailableSports { get; set; } = new List<Sport>();

        public ICollection<Amenity> AvailableAmenities { get; set; } = new List<Amenity>();

        public ICollection<Facility> Facilities { get; set; } = new List<Facility>();

    }
}
