using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class Role
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string? Name { get; set; }

        [MaxLength(100)]
        public string? RoleDescription { get; set; }
    }
}
