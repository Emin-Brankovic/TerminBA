using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class RoleResponse
    {
        public int Id { get; set; }

        public string? RoleName { get; set; }

        public string? RoleDescription { get; set; }
    }
}


