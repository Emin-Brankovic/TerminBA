namespace TerminBA.Services.Recommender
{
    public static class FeatureBuilder
    {
        public const double TimeFitToleranceMinutes = 120.0;
        public const double RoutineToleranceMinutes = 30.0;
        private const float BayesianPriorWeight = 3f;

        public static CandidateFeatures Build(
            UserProfile user,
            TimeSlotCandidate slot,
            UserTimeWindow window)
        {
            var dow = slot.StartTime.DayOfWeek;
            var startTod = slot.StartTime.TimeOfDay;

            float sportMatch = Math.Min(1f, slot.SportIds
                .Distinct()
                .Sum(id => user.SportPreference.GetValueOrDefault(id)));

            bool offersMostBookedSport = user.MostBookedSportId.HasValue
                && slot.SportIds.Contains(user.MostBookedSportId.Value);

            float centerAffinity = user.SportCenterAffinity.GetValueOrDefault(slot.SportCenterId);

            float cityPreference = slot.CityId.HasValue
                ? user.CityPreference.GetValueOrDefault(slot.CityId.Value)
                : 0f;
            bool inHomeCity = slot.CityId.HasValue && slot.CityId == user.HomeCityId;
            float locationMatch = Math.Max(cityPreference, inHomeCity ? 0.6f : 0f);

            float indoorMatch = 1f - Math.Abs((slot.IsIndoor ? 1f : 0f) - user.IndoorPreference);
            float turfMatch = user.TurfTypePreference.GetValueOrDefault(slot.TurfTypeId);
            float attributeMatch = (indoorMatch + turfMatch) / 2f;

            float priceDiff = Math.Abs((float)slot.Price - (float)user.AveragePaidPrice);
            float priceFit = user.AveragePaidPrice > 0
                ? Math.Max(0f, 1f - priceDiff / (float)user.AveragePaidPrice)
                : 0.5f;

            double minutesDiff = MinutesFromUsualStart(window, dow, startTod);
            float timeWindowFit = (float)Math.Max(0.0, 1.0 - minutesDiff / TimeFitToleranceMinutes);
            float dayFit = window.DayFrequency.GetValueOrDefault(dow);
            float routineMatch = MatchesRoutine(window, dow, startTod) ? 1f : 0f;

            user.UserRatingPerFacility.TryGetValue(slot.FacilityId, out float userRating);
            user.OverallRatingPerFacility.TryGetValue(slot.FacilityId, out float overallRating);
            user.ReviewCountPerFacility.TryGetValue(slot.FacilityId, out int reviewCount);

            float smoothedRating = (overallRating * reviewCount + user.GlobalAverageRating * BayesianPriorWeight)
                                   / (reviewCount + BayesianPriorWeight);

            user.BookingCountPerFacility.TryGetValue(slot.FacilityId, out int bookingCount);

            return new CandidateFeatures
            {
                SportMatchScore = sportMatch,
                SportCenterAffinity = centerAffinity,
                LocationMatchScore = locationMatch,
                FacilityAttributeMatchScore = attributeMatch,
                PriceFitScore = priceFit,
                TimeWindowFitScore = timeWindowFit,
                DayOfWeekFitScore = dayFit,
                RoutineMatch = routineMatch,
                FacilityQualityScore = Math.Clamp(smoothedRating / 5f, 0f, 1f),

                FacilityAvgUserRating = userRating,
                FacilityAvgOverallRating = overallRating,
                FacilityReviewCount = reviewCount,
                PreviouslyBookedFacility = bookingCount > 0 ? 1f : 0f,
                PreviouslyBookedSportCenter = user.BookedSportCenterIds.Contains(slot.SportCenterId) ? 1f : 0f,
                FacilityBookingFrequency = bookingCount,
                PriceDiffFromUserAvg = priceDiff,
                OffersMostBookedSport = offersMostBookedSport
            };
        }

        public static double MinutesFromUsualStart(UserTimeWindow window, DayOfWeek day, TimeSpan startTime)
        {
            double minutes = Math.Abs((startTime - window.MedianStart).TotalMinutes);

            foreach (var routine in window.RoutineSlots)
            {
                if (routine.Day != day)
                    continue;

                minutes = Math.Min(minutes, Math.Abs((startTime - routine.Start).TotalMinutes));
            }

            return minutes;
        }

        public static bool MatchesRoutine(UserTimeWindow window, DayOfWeek day, TimeSpan startTime)
        {
            return window.RoutineSlots.Any(r =>
                r.Day == day &&
                Math.Abs((startTime - r.Start).TotalMinutes) <= RoutineToleranceMinutes);
        }
    }
}
