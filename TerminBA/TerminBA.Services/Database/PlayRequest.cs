using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    //treba se jos doraditi (mozda), ne praviti nista posebno za nju u context klasi jos
    public class PlayRequest
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(Post))] // iz posta izvuci rezervaciju i iz rezervacije usera koji je napravio post
        public int PostId { get; set; }
        public Post? Post { get; set; }

        [ForeignKey(nameof(User))]
        public int RequesterId { get; set; }
        public User? Requester{ get; set; }

    }
}
