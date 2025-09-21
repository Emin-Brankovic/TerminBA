using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.SearchObjects
{
    public class PlayRequestSearchObject : BaseSearchObject
    {
        public int? PostId { get; set; }
        public int? RequesterId { get; set; }
    }
}
