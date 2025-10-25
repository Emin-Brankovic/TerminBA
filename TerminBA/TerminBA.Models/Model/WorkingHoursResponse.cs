using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Enums;

namespace TerminBA.Models.Model
{
    public class WorkingHoursResponse
    {
        public int Id { get; set; }

        public int SportCenterId { get; set; }

        public DayOfWeek StartDay { get; set; }

        public DayOfWeek EndDay { get; set; }

        public TimeOnly OpeningHours { get; set; }

        public TimeOnly CloseingHours { get; set; }

        public DateOnly ValidFrom { get; set; }

        public DateOnly ValidTo { get; set; }
    }
}



