using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.SearchObjects
{
    public class RoleSearchObject : BaseSearchObject
    {
        public string? RoleName { get; set; }

        public string? FTS { get; set; }
    }
}


