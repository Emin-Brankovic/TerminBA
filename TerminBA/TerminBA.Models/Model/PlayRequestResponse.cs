using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class PlayRequestResponse
    {
        public int Id { get; set; }
        public int PostId { get; set; }
        public PostResponse? Post{ get; set; }

        public int RequesterId { get; set; }
        public UserResponse? Requester { get; set; }

        public bool? isAccepted { get; set; }  // false = denied, true = accepted

        public string? RequestText { get; set; }

        public DateTime? DateOfRequest { get; set; }
        public DateTime? DateOfResponse { get; set; }
    }
}



