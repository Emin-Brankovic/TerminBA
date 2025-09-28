using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.SearchObjects
{
    public class SportCenterSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public int? CityId { get; set; }
        public int? UserId { get; set; }
        public bool? IsEquipmentProvided { get; set; }
    }
}

