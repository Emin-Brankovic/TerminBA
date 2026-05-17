using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class SportCenterPhoto : PhotoBase
    {
        [Required]
        public int SportCenterId { get; set; }
        public SportCenter? SportCenter { get; set; }
    }
}
