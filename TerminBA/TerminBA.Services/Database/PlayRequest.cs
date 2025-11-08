using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class PlayRequest
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [ForeignKey(nameof(Post))] // iz posta izvuci rezervaciju i iz rezervacije usera koji je napravio post
        public int PostId { get; set; }
        public Post? Post { get; set; }

        [Required]
        [ForeignKey(nameof(User))]
        public int RequesterId { get; set; }
        public User? Requester{ get; set; }

        public bool? isAccepted { get; set; } = null; // false = denied, true = accepted

        [MaxLength(100)]
        public string? RequestText { get; set; }

        [Required]
        public DateTime? DateOfRequest { get; set; } = DateTime.Now;
        public DateTime? DateOfResponse { get; set; }

    }
}
