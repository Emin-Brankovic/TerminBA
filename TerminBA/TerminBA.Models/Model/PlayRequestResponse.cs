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

        public string PlayRequestState { get; set; } = "PendingPlayRequestState";
        public bool? isAccepted => PlayRequestState == "PendingPlayRequestState" ? null : PlayRequestState == "AcceptedPlayRequestState";

        public string? Reason { get; set; }
        public DateTime? RespondedAt { get; set; }
        public int? RespondedById { get; set; }
        public DateTime? CanceledAt { get; set; }
        public int? CanceledById { get; set; }
        public string? RequestText { get; set; }

        public DateTime? DateOfRequest { get; set; }
        public DateTime? DateOfResponse { get; set; }

        public bool IsSeenByOwner { get; set; }
        public bool IsSeenByRequester { get; set; }
    }
}



