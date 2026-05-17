using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class SportCenterPhotoResponse
    {
        public int Id { get; set; }
        public string? Url { get; set; }
        public string? PublicId { get; set; }
        public int SportCenterId { get; set; }
        public bool? IsMain { get; set; }
    }
}
