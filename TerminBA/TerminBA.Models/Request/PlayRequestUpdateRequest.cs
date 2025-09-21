using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Request
{
    public class PlayRequestUpdateRequest
    {
        [Required]
        public int PostId { get; set; }

        [Required]
        public int RequesterId { get; set; }
    }
}




