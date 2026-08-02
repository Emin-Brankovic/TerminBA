using System.ComponentModel.DataAnnotations;

namespace TerminBA.Models.Request
{
    public class PlayRequestRespondRequest
    {
        [Required]
        public bool IsAccepted { get; set; }

        public string? Reason { get; set; }
    }
}
