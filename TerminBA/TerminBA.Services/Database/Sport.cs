using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class Sport
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public required string SportName { get; set; }

        public ICollection<SportCenter> SportCentars { get; set; } = new List<SportCenter>();
        public ICollection<Facility> Facilities { get; set; } = new List<Facility>();
    }
}
