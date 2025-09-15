using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Request
{
    public class RoleInsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string? RoleName { get; set; }

        [MaxLength(100)]
        public string? RoleDescription { get; set; }
    }
}


