using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class FacilityPhoto
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public string? Url { get; set; }
        [Required]
        public string? PublicId { get; set; }
        [Required]
        public int FacilityId { get; set; }
        public Facility? Facility { get; set; }
        public bool? IsMain { get; set; }
    }
}
