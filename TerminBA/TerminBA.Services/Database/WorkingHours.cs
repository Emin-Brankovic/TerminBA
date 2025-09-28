using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Enums;

namespace TerminBA.Services.Database
{
    public class WorkingHours
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(SportCentar))]
        [Required]
        public int SportCenterId { get; set; }
        public SportCenter? SportCentar { get; set; }

        [Required]
        public DayOfWeekEnum StartDay { get; set; }
        [Required]
        public DayOfWeekEnum EndDay { get;set; }

        [Required]
        public TimeOnly OpeningHours { get; set; }
        [Required]
        public TimeOnly CloseingHours { get;set; }

        [Required]
        public DateOnly ValidFrom { get; set; }
        [Required]
        public DateOnly ValidTo { get; set; }

    }
}
