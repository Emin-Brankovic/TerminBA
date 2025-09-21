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

        public int RequesterId { get; set; }
    }
}



