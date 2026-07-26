namespace TerminBA.Services.Recommender
{
    public static class FeatureBuilder
    {
        public static RecommendationInput Build(
            UserProfile user,
            TimeSlotCandidate slot,
            UserTimeWindow window)
        {
            float sportTypeMatch = user.MostBookedSportId.HasValue
                && slot.SportIds.Contains(user.MostBookedSportId.Value) ? 1f : 0f;

            user.UserRatingPerFacility.TryGetValue(slot.FacilityId, out float facilityAvgUserRating);

            user.OverallRatingPerFacility.TryGetValue(slot.FacilityId, out float facilityAvgOverallRating);

            user.BookingCountPerFacility.TryGetValue(slot.FacilityId, out int bookingCount);
            float previouslyBooked = bookingCount > 0 ? 1f : 0f;

            float priceDiff = Math.Abs((float)slot.Price - (float)user.AveragePaidPrice);

            double minutesDiff = Math.Abs(
                (slot.StartTime.TimeOfDay - window.MedianStart).TotalMinutes);
            float timeWindowFitScore = (float)Math.Max(0.0, 1.0 - minutesDiff / 120.0);

            return new RecommendationInput
            {
                SportTypeMatch = sportTypeMatch,
                FacilityAvgUserRating = facilityAvgUserRating,
                FacilityAvgOverallRating = facilityAvgOverallRating,
                PreviouslyBookedFacility = previouslyBooked,
                PriceDiffFromUserAvg = priceDiff,
                FacilityBookingFrequency = bookingCount,
                TimeWindowFitScore = timeWindowFitScore
            };
        }
    }
}
