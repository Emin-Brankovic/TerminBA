using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Linq.Expressions;
using System.Xml;

namespace TerminBA.Services.Database
{
    public class FacilityDynamicPrice
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [ForeignKey(nameof(Facility))]
        public int FacilityId { get; set; }
        public Facility? Facility { get; set; }

        [Required]
        public DayOfWeek StartDay { get; set; }
        [Required]
        public DayOfWeek EndDay { get; set; }

        [Required]
        public TimeOnly StartTime { get; set; }
        [Required]
        public TimeOnly EndTime { get; set; }

        [Required]
        [Column(TypeName = "decimal(10,2)")]
        public decimal PricePerHour { get; set; }

        [NotMapped]
        public bool IsActive =>
              (ValidFrom <= DateOnly.FromDateTime(DateTime.Today)) &&
              (ValidTo == null || ValidTo >= DateOnly.FromDateTime(DateTime.Today));

        public static Expression<Func<FacilityDynamicPrice, bool>> IsActiveExpr(DateOnly today) =>
            x => x.ValidFrom <= today &&
            (x.ValidTo == null || x.ValidTo >= today);

        [Required]
        public DateOnly ValidFrom { get; set; }

        public DateOnly? ValidTo { get; set; }
    }
}
