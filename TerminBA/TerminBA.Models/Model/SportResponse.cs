using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class SportResponse
    {
        public int Id { get; set; }

        public string? SportName { get; set; }

        //public ICollection<SportCenter> SportCentars { get; set; } = new List<SportCenter>();
        //public ICollection<Facility> Facilities { get; set; } = new List<Facility>();
    }
}
