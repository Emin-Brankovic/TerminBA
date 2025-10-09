using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class AccountBase
    {

        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        [MinLength(2)]
        public string? Username { get; set; }


        [Phone(ErrorMessage = "Not valid phone number format")]
        public string? PhoneNumber { get; set; }

        [Required]
        public string PasswordSalt { get; set; } = string.Empty;

        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        [Url(ErrorMessage = "Not a valid url")]
        public string? InstagramAccount { get; set; }

        [ForeignKey(nameof(Role))]
        [Required]
        public int RoleId { get; set; }
        public Role? Role { get; set; }

        [ForeignKey(nameof(City))]
        [Required]
        public int CityId { get; set; }
        public City? City { get; set; }
    }
}
