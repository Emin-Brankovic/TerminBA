using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Request
{
    public class PlayRequestInsertRequest
    {
        [Required]
        public int PostId { get; set; }

        [Required]
        public int RequesterId { get; set; }

        public bool? isAccepted { get; set; } = false; // false = denied, true = accepted

        [MaxLength(100)]
        public string? RequestText { get; set; }

        public DateTime? DateOfRequest { get; set; }=DateTime.Now;
        public DateTime? DateOfResponse { get; set; }
    }
}




