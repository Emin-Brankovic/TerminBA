using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
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
        public DayOfWeek StartDay { get; set; }
        [Required]
        public DayOfWeek EndDay { get;set; }

        [Required]
        public TimeOnly OpeningHours { get; set; }
        [Required]
        public TimeOnly CloseingHours { get;set; }

        [Required]
        public DateOnly ValidFrom { get; set; }
        public DateOnly? ValidTo { get; set; } // can be null if the working hours are constant

        [NotMapped]
        public bool IsActive =>
            (ValidFrom <= DateOnly.FromDateTime(DateTime.Today)) &&
            (ValidTo == null || ValidTo >= DateOnly.FromDateTime(DateTime.Today));

        //public static Expression<Func<WorkingHours, bool>> IsActiveExpr(DateOnly today) =>
        // x => x.ValidFrom <= today &&
        //    (x.ValidTo == null || x.ValidTo >= today);
    }
}
