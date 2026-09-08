using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.ComponentModel.DataAnnotations;

namespace TerminBA.Models.SearchObjects
{
    public class BaseSearchObject
    {
        public string? FTS { get; set; }

        public int? Page { get; set; } = 1;

        public int? PageSize { get; set; } = 10;
    }
}
