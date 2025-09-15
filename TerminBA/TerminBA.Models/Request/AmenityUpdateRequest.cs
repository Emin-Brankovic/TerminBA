using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Request
{
    public class AmenityUpdateRequest
    {
        [Required]
        [MaxLength(50)]
        public required string Name { get; set; }
    }
}


