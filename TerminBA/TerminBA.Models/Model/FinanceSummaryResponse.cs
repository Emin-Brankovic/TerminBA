using System.Collections.Generic;

namespace TerminBA.Models.Model
{
    public class FinanceSummaryResponse
    {
        public decimal TodayRevenue { get; set; }
        public decimal MonthRevenue { get; set; }
        public string MonthLabel { get; set; } = string.Empty;
        public List<FinanceDailyRevenuePointResponse> DailyRevenuePoints { get; set; } = new();
    }

    public class FinanceDailyRevenuePointResponse
    {
        public int Day { get; set; }
        public decimal Revenue { get; set; }
    }
}