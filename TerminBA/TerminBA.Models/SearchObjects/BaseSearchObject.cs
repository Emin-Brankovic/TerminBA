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

        //[Range(1, int.MaxValue, ErrorMessage = "Page must be greater than 0.")]
        public int? Page { get; set; } = 1;

        //[Range(1, 30, ErrorMessage = "PageSize must be between 1 and 30.")]
        public int? PageSize { get; set; } = 10;
    }
}
