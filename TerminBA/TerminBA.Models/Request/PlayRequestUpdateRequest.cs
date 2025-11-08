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

        public bool? isAccepted { get; set; }
        [MaxLength(100)]
        public string? RequestText { get; set; }

    }
}




