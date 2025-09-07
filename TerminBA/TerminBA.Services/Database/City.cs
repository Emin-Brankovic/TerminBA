using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class City
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        [MinLength(2)]
        public required string Name { get; set; }

        public ICollection<SportCenter> SportCenters { get; set; } = new List<SportCenter>();
        public ICollection<User> Users { get; set; } = new List<User>();
    }
}
