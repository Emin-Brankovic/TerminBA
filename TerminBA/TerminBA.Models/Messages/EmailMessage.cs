using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Messages
{
    public class EmailMessage
    {
        public string? RecipientEmail { get; set; }
        public string? MessageBody { get; set; }
    }
}
