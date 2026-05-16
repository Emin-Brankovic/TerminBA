using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;

namespace TerminBA.Services.Database
{
    public class FacilityPhotoResponse
    {
        public int Id { get; set; }
        public string? Url { get; set; }
        public string? PublicId { get; set; }
        public int FacilityId { get; set; }
        public bool? IsMain { get; set; }
    }
}
