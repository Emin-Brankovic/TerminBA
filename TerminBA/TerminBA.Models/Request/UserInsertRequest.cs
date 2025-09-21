using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Request
{
    public class UserInsertRequest
    {
        [Required]
        [MaxLength(50)]
        [MinLength(2)]
        public string? FirstName { get; set; }

        [Required]
        [MaxLength(50)]
        [MinLength(2)]
        public string? LastName { get; set; }

        [Range(14, 100)]
        public int Age { get; set; }

        [Required]
        [MaxLength(30)]
        [MinLength(2)]
        public string? Username { get; set; }

        [Required]
        [EmailAddress]
        public string? Email { get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        [Url]
        public string? InstagramAccount { get; set; }

        [Required]
        public string? Password { get; set; }

        [Required]
        public DateOnly BirthDate { get; set; }

        [Required]
        public int CityId { get; set; }

        [Required]
        public int RoleId { get; set; }
    }
}




