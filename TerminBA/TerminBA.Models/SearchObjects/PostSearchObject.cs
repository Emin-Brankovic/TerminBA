using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.SearchObjects
{
    public class PostSearchObject : BaseSearchObject
    {
        public string? SkillLevel { get; set; }
        public int? ReservationId { get; set; }
        public int? SportId { get; set; }
    }
}


