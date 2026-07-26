using Microsoft.ML.Data;

namespace TerminBA.Services.Recommender
{
    public class RecommendationInput
    {
        [LoadColumn(0)]
        public float SportTypeMatch { get; set; }

        [LoadColumn(1)]
        public float FacilityAvgUserRating { get; set; }

        [LoadColumn(2)]
        public float FacilityAvgOverallRating { get; set; }

        [LoadColumn(3)]
        public float PreviouslyBookedFacility { get; set; }

        [LoadColumn(4)]
        public float PriceDiffFromUserAvg { get; set; }

        [LoadColumn(5)]
        public float FacilityBookingFrequency { get; set; }

        [LoadColumn(6)]
        public float TimeWindowFitScore { get; set; }

        [LoadColumn(7), ColumnName("Label")]
        public bool Booked { get; set; }
    }
}
