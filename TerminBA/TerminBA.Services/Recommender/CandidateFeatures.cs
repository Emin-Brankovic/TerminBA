namespace TerminBA.Services.Recommender
{
    public class CandidateFeatures
    {
        public float SportMatchScore { get; set; }

        public float SportCenterAffinity { get; set; }

        public float LocationMatchScore { get; set; }

        public float FacilityAttributeMatchScore { get; set; }

        public float PriceFitScore { get; set; }
        
        public float TimeWindowFitScore { get; set; }

        public float DayOfWeekFitScore { get; set; }

        public float RoutineMatch { get; set; }
        
        public float FacilityQualityScore { get; set; }

        public float FacilityAvgUserRating { get; set; }

        public float FacilityAvgOverallRating { get; set; }

        public int FacilityReviewCount { get; set; }

        public float PreviouslyBookedFacility { get; set; }

        public float PreviouslyBookedSportCenter { get; set; }

        public int FacilityBookingFrequency { get; set; }

        public float PriceDiffFromUserAvg { get; set; }

        public bool OffersMostBookedSport { get; set; }
    }
}
