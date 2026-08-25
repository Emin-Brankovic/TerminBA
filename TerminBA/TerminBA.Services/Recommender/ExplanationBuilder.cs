namespace TerminBA.Services.Recommender
{
    public static class ExplanationBuilder
    {
        public static List<string> Build(
            RecommendationInput input,
            UserProfile user,
            TimeSlotCandidate slot,
            UserTimeWindow window)
        {
            var reasons = new List<string>();

            reasons.Add($"The slot is available during your usual playing time.");

            if (input.PreviouslyBookedFacility >= 1f)
                reasons.Add($"You previously booked a court at {slot.FacilityName}.");

            if (input.FacilityAvgUserRating >= 4f)
                reasons.Add("You previously rated this or a similar court highly.");

            if (input.SportTypeMatch >= 1f)
                reasons.Add("Matches the sport you play most often.");

            if (input.FacilityAvgOverallRating >= 4f)
                reasons.Add("Other users rate this center highly.");

            if (input.TimeWindowFitScore >= 0.8f)
                reasons.Add("The time slot perfectly matches your favorite playing time.");

            if (reasons.Count == 1)
                reasons.Add("Recommended based on similarity with your previous bookings.");

            return reasons;
        }

        public static List<string> BuildFallback(float overallRating)
        {
            var reasons = new List<string>
            {
                "Recommended as a popular court in your area."
            };

            if (overallRating >= 4f)
                reasons.Add("Other users rate this center highly.");

            return reasons;
        }
    }
}
