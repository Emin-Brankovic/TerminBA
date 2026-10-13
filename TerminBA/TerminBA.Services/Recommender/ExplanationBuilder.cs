namespace TerminBA.Services.Recommender
{
    public static class ExplanationBuilder
    {
        private const int MaxReasons = 4;

        public static List<string> Build(
            CandidateFeatures features,
            UserProfile user,
            TimeSlotCandidate slot,
            UserTimeWindow window)
        {
            var reasons = new List<string>();
            var day = slot.StartTime.DayOfWeek;

            if (features.RoutineMatch >= 1f)
                reasons.Add($"The court is free at your regular {day} time ({slot.StartTime:HH:mm}).");
            else if (features.TimeWindowFitScore >= 0.8f)
                reasons.Add("The court is free at your favorite playing time.");
            else
                reasons.Add("The slot is available during your usual playing time.");

            if (features.PreviouslyBookedFacility >= 1f)
                reasons.Add($"You previously booked a court at {slot.FacilityName}.");
            else if (features.PreviouslyBookedSportCenter >= 1f && !string.IsNullOrWhiteSpace(slot.SportCenterName))
                reasons.Add($"You have played at {slot.SportCenterName} before.");

            if (features.FacilityAvgUserRating >= 4f)
                reasons.Add("You rated this court highly.");

            if (features.OffersMostBookedSport)
                reasons.Add("Matches the sport you play most often.");

            if (features.RoutineMatch < 1f && features.DayOfWeekFitScore >= 0.8f)
                reasons.Add($"You often play on {day}s.");

            if (features.PreviouslyBookedSportCenter < 1f && features.LocationMatchScore >= 0.8f)
                reasons.Add("Located in the area where you usually play.");

            if (features.FacilityAttributeMatchScore >= 0.8f)
                reasons.Add($"Same type of court you usually book ({(slot.IsIndoor ? "indoor" : "outdoor")}).");

            if (features.PriceFitScore >= 0.8f)
                reasons.Add("The price is in line with what you usually pay.");

            if (features.FacilityAvgOverallRating >= 4f && features.FacilityReviewCount > 0)
                reasons.Add("Other users rate this center highly.");

            if (reasons.Count == 1)
                reasons.Add("Recommended based on similarity with your previous bookings.");

            return reasons.Take(MaxReasons).ToList();
        }

        public static List<string> BuildFallback(
            float overallRating,
            int reviewCount,
            bool isPopular,
            bool isInUserCity)
        {
            var reasons = new List<string>
            {
                isInUserCity
                    ? "Recommended as a popular court in your area."
                    : "Recommended as a popular court."
            };

            if (overallRating >= 4f && reviewCount > 0)
                reasons.Add("Other users rate this center highly.");

            if (isPopular)
                reasons.Add("Frequently booked by other players.");

            reasons.Add("This is the next available slot at this court.");

            return reasons.Take(MaxReasons).ToList();
        }
    }
}
