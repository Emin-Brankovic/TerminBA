using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class CityResponse
    {
        public int Id { get; set; }

        public required string Name { get; set; }

        //public ICollection<SportCenter> SportCenters { get; set; } = new List<SportCenter>();
        //public ICollection<User> Users { get; set; } = new List<User>();
    }
}
