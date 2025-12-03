using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.SearchObjects
{
    public class FacilitySearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public int? SportCenterId { get; set; }
        public int? TurfTypeId { get; set; }
        public bool? IsIndoor { get; set; }
        public int? SportId { get; set; }
        //public DateOnly? WantedDate { get; set; }
        public double? MinPrice { get; set; }
        public double? MaxPrice { get; set; }
    }
}

