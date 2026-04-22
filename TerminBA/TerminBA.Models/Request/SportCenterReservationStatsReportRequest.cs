using System.ComponentModel.DataAnnotations;

namespace TerminBA.Models.Request
{
    public class SportCenterReservationStatsReportRequest
    {
        public DateOnly? FromDate { get; set; }
        public DateOnly? ToDate { get; set; }

        public byte[]? ChartImage { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Total reservations must be non-negative.")]
        public int TotalReservations { get; set; }

        public Dictionary<string, int>? CountBySport { get; set; }

        public Dictionary<string, int>? CountByFacility { get; set; }
    }
}
