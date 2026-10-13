using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;
using TerminBA.Services.Recommender;
using TerminBA.Services.ReservationStateMachine;

namespace TerminBA.Services.Service
{
    public class RecommendationService : IRecommendationService
    {
        private readonly TerminBaContext _db;

        private const int CandidateDaysAhead = 14;
        private const int MinCompletedReservationsForPersonalization = 3;
        private const int MinOccurrencesForRoutine = 2;
        private const double RecencyHalfLifeDays = 120.0;
        private const double MinRecencyWeight = 0.25;
        private const int PopularityLookbackDays = 90;

        private const float WeightSport = 0.22f;
        private const float WeightTimeOfDay = 0.17f;
        private const float WeightSportCenter = 0.13f;
        private const float WeightDayOfWeek = 0.10f;
        private const float WeightQuality = 0.10f;
        private const float WeightLocation = 0.08f;
        private const float WeightPrice = 0.08f;
        private const float WeightFacilityAttributes = 0.07f;
        private const float WeightRoutine = 0.05f;

        private const float DislikedFacilityPenalty = 0.5f;

        private const float FallbackWeightRating = 0.60f;
        private const float FallbackWeightPopularity = 0.25f;
        private const float FallbackWeightCity = 0.15f;

        public RecommendationService(TerminBaContext db)
        {
            _db = db;
        }

        public async Task<List<RecommendationResult>> GetRecommendationsAsync(int userId, int topN = 5)
        {
            var userReservations = await _db.Reservations
                .AsNoTracking()
                .Include(r => r.Facility)
                    .ThenInclude(f => f!.AvailableSports)
                .Include(r => r.Facility)
                    .ThenInclude(f => f!.SportCenter)
                .Where(r => r.UserId == userId &&
                    r.Status != nameof(CanceledReservationState) &&
                    r.Status != nameof(CanceledWithRefundReservationState) &&
                    r.Status != nameof(CanceledWithoutRefundReservationState))
                .ToListAsync();

            var completedReservations = userReservations.Where(IsCompleted).ToList();
            var window = DeriveUserTimeWindow(completedReservations);

            if (!window.HasEnoughHistory)
                return await GetFallbackRecommendationsAsync(userId, topN);

            var candidateSlots = await GetAvailableSlotsAsync(userId, window);

            if (candidateSlots.Count == 0)
                return await GetFallbackRecommendationsAsync(userId, topN);

            var userProfile = await BuildUserProfileAsync(userId, userReservations);

            var scored = candidateSlots
                .Select(slot =>
                {
                    var features = FeatureBuilder.Build(userProfile, slot, window);
                    return (Slot: slot, Features: features, Score: CalculateContentBasedScore(features));
                })
                .OrderByDescending(x => x.Score)
                .ThenBy(x => x.Slot.StartTime)
                .ToList();

            var selected = scored
                .GroupBy(x => x.Slot.FacilityId)
                .Select(g => g.First())
                .OrderByDescending(x => x.Score)
                .ThenBy(x => x.Slot.StartTime)
                .Take(topN)
                .ToList();

            if (selected.Count < topN)
            {
                var fill = scored
                    .Where(x => !selected.Contains(x))
                    .Take(topN - selected.Count)
                    .ToList();

                selected.AddRange(fill);
            }

            var topResults = selected
                .Select(x => new RecommendationResult
                {
                    FacilityId = x.Slot.FacilityId,
                    FacilityName = x.Slot.FacilityName,
                    SportCenterName = x.Slot.SportCenterName,
                    StartTime = x.Slot.StartTime,
                    EndTime = x.Slot.EndTime,
                    Price = x.Slot.Price,
                    Score = x.Score,
                    Reasons = ExplanationBuilder.Build(x.Features, userProfile, x.Slot, window),
                    IsPersonalized = true
                })
                .ToList();

            await LogRecommendationEventsAsync(userId, topResults);

            return topResults;
        }

        private static float CalculateContentBasedScore(CandidateFeatures f)
        {
            float score =
                WeightSport * f.SportMatchScore +
                WeightTimeOfDay * f.TimeWindowFitScore +
                WeightSportCenter * f.SportCenterAffinity +
                WeightDayOfWeek * f.DayOfWeekFitScore +
                WeightQuality * f.FacilityQualityScore +
                WeightLocation * f.LocationMatchScore +
                WeightPrice * f.PriceFitScore +
                WeightFacilityAttributes * f.FacilityAttributeMatchScore +
                WeightRoutine * f.RoutineMatch;

            if (f.FacilityAvgUserRating > 0f && f.FacilityAvgUserRating <= 2f)
                score *= DislikedFacilityPenalty;

            return Math.Clamp(score, 0f, 1f);
        }

        private static UserTimeWindow DeriveUserTimeWindow(List<Reservation> completedReservations)
        {
            if (completedReservations.Count < MinCompletedReservationsForPersonalization)
                return new UserTimeWindow { HasEnoughHistory = false };

            var today = DateOnly.FromDateTime(TimeHelper.GetFacilityNow());

            var dayWeights = completedReservations
                .GroupBy(r => r.ReservationDate.DayOfWeek)
                .ToDictionary(g => g.Key, g => (float)g.Sum(r => RecencyWeight(r.ReservationDate, today)));

            float maxDayWeight = dayWeights.Values.Max();

            var dayFrequency = dayWeights.ToDictionary(kv => kv.Key, kv => kv.Value / maxDayWeight);

            var preferredDays = dayWeights
                .OrderByDescending(kv => kv.Value)
                .Take(2)
                .Select(kv => kv.Key)
                .ToList();

            var startTimes = completedReservations
                .Select(r => r.StartTime.ToTimeSpan())
                .OrderBy(t => t)
                .ToList();

            var endTimes = completedReservations
                .Select(r => r.EndTime.ToTimeSpan())
                .OrderBy(t => t)
                .ToList();

            var medianStart = startTimes[startTimes.Count / 2];
            var medianEnd = endTimes[endTimes.Count / 2];

            var routineSlots = completedReservations
                .GroupBy(r => (Day: r.ReservationDate.DayOfWeek, Start: RoundToHalfHour(r.StartTime.ToTimeSpan())))
                .Where(g => g.Count() >= MinOccurrencesForRoutine)
                .Select(g => new RoutineSlot
                {
                    Day = g.Key.Day,
                    Start = g.Key.Start,
                    Occurrences = g.Count()
                })
                .OrderByDescending(r => r.Occurrences)
                .ToList();

            return new UserTimeWindow
            {
                PreferredDays = preferredDays,
                DayFrequency = dayFrequency,
                MedianStart = medianStart,
                PreferredStart = medianStart.Add(TimeSpan.FromMinutes(-30)),
                PreferredEnd = medianEnd.Add(TimeSpan.FromMinutes(30)),
                RoutineSlots = routineSlots,
                HasEnoughHistory = true
            };
        }

        private async Task<UserProfile> BuildUserProfileAsync(int userId, List<Reservation> reservations)
        {
            var today = DateOnly.FromDateTime(TimeHelper.GetFacilityNow());

            var homeCityId = await GetUserCityIdAsync(userId);

            var userReviews = await _db.FacilityReviews
                .AsNoTracking()
                .Where(fr => fr.UserId == userId && fr.FacilityId != null)
                .ToListAsync();

            var userRatingPerFacility = userReviews
                .GroupBy(fr => fr.FacilityId!.Value)
                .ToDictionary(g => g.Key, g => (float)g.Average(fr => fr.RatingNumber));

            var userRatingPerReservation = userReviews
                .Where(fr => fr.ReservationId != null)
                .GroupBy(fr => fr.ReservationId!.Value)
                .ToDictionary(g => g.Key, g => (float)g.Average(fr => fr.RatingNumber));

            var (overallRatings, reviewCounts, globalAverage) = await GetFacilityRatingStatsAsync();

            var sportWeights = new Dictionary<int, float>();
            var centerWeights = new Dictionary<int, float>();
            var cityWeights = new Dictionary<int, float>();
            var turfWeights = new Dictionary<int, float>();
            float indoorWeight = 0f;
            float totalWeight = 0f;

            foreach (var reservation in reservations)
            {
                var facility = reservation.Facility;
                if (facility == null)
                    continue;

                float rating = userRatingPerReservation.TryGetValue(reservation.Id, out var reservationRating)
                    ? reservationRating
                    : userRatingPerFacility.GetValueOrDefault(facility.Id);

                float weight = (float)RecencyWeight(reservation.ReservationDate, today) * RatingWeight(rating);

                if (reservation.ChosenSportId.HasValue)
                {
                    AddWeight(sportWeights, reservation.ChosenSportId.Value, weight);
                }
                else if (facility.AvailableSports.Count > 0)
                {
                    float share = weight / facility.AvailableSports.Count;
                    foreach (var sport in facility.AvailableSports)
                        AddWeight(sportWeights, sport.Id, share);
                }

                AddWeight(centerWeights, facility.SportCenterId, weight);
                AddWeight(turfWeights, facility.TurfTypeId, weight);

                if (facility.SportCenter != null)
                    AddWeight(cityWeights, facility.SportCenter.CityId, weight);

                if (facility.IsIndoor)
                    indoorWeight += weight;

                totalWeight += weight;
            }

            int? mostBookedSportId = sportWeights.Count > 0
                ? sportWeights.OrderByDescending(kv => kv.Value).First().Key
                : null;

            var paidReservations = reservations.Where(r => r.Price > 0).ToList();
            decimal avgPrice = paidReservations.Count > 0
                ? paidReservations.Average(r => r.Price)
                : 0m;

            var bookingCount = reservations
                .Where(r => r.FacilityId.HasValue)
                .GroupBy(r => r.FacilityId!.Value)
                .ToDictionary(g => g.Key, g => g.Count());

            var bookedSportCenterIds = reservations
                .Where(r => r.Facility != null)
                .Select(r => r.Facility!.SportCenterId)
                .ToHashSet();

            return new UserProfile
            {
                UserId = userId,
                HomeCityId = homeCityId,
                MostBookedSportId = mostBookedSportId,
                SportPreference = NormalizeToSum(sportWeights),
                SportCenterAffinity = NormalizeToMax(centerWeights),
                CityPreference = NormalizeToMax(cityWeights),
                TurfTypePreference = NormalizeToMax(turfWeights),
                IndoorPreference = totalWeight > 0 ? indoorWeight / totalWeight : 0.5f,
                AveragePaidPrice = avgPrice,
                BookingCountPerFacility = bookingCount,
                BookedSportCenterIds = bookedSportCenterIds,
                UserRatingPerFacility = userRatingPerFacility,
                OverallRatingPerFacility = overallRatings,
                ReviewCountPerFacility = reviewCounts,
                GlobalAverageRating = globalAverage
            };
        }

        private async Task<List<TimeSlotCandidate>> GetAvailableSlotsAsync(
            int userId,
            UserTimeWindow? window,
            List<int>? facilityIdFilter = null)
        {
            var facilitiesQuery = _db.Facilities
                .AsNoTracking()
                .Include(f => f.SportCenter)
                    .ThenInclude(sc => sc!.WorkingHours)
                .Include(f => f.AvailableSports)
                .Include(f => f.DynamicPrices)
                .AsQueryable();

            if (facilityIdFilter != null)
                facilitiesQuery = facilitiesQuery.Where(f => facilityIdFilter.Contains(f.Id));

            var facilities = await facilitiesQuery.ToListAsync();

            var today = TimeHelper.GetFacilityNow().Date;
            var windowStart = DateOnly.FromDateTime(today.AddDays(1));
            var windowEnd = DateOnly.FromDateTime(today.AddDays(CandidateDaysAhead));
            var facilityIds = facilities.Select(f => f.Id).ToList();

            var activeReservations = await _db.Reservations
                .AsNoTracking()
                .Where(r =>
                    r.ReservationDate >= windowStart &&
                    r.ReservationDate <= windowEnd &&
                    r.Status != nameof(CanceledReservationState) &&
                    r.Status != nameof(CanceledWithRefundReservationState) &&
                    r.Status != nameof(CanceledWithoutRefundReservationState) &&
                    ((r.FacilityId != null && facilityIds.Contains(r.FacilityId!.Value)) || r.UserId == userId))
                .Select(r => new
                {
                    r.FacilityId,
                    r.UserId,
                    r.ReservationDate,
                    r.StartTime,
                    r.EndTime
                })
                .ToListAsync();

            var facilityReservations = activeReservations
                .Where(r => r.FacilityId != null)
                .GroupBy(r => (FacilityId: r.FacilityId!.Value, r.ReservationDate))
                .ToDictionary(g => g.Key, g => g.Select(r => (r.StartTime, r.EndTime)).ToList());

            var userReservations = activeReservations
                .Where(r => r.UserId == userId)
                .GroupBy(r => r.ReservationDate)
                .ToDictionary(g => g.Key, g => g.Select(r => (r.StartTime, r.EndTime)).ToList());

            var candidates = new List<TimeSlotCandidate>();

            foreach (var facility in facilities)
            {
                if (facility.Duration <= TimeSpan.Zero || facility.SportCenter == null)
                    continue;

                var sportIds = facility.AvailableSports.Select(s => s.Id).ToList();

                for (int dayOffset = 1; dayOffset <= CandidateDaysAhead; dayOffset++)
                {
                    var date = today.AddDays(dayOffset);
                    var dow = date.DayOfWeek;
                    var dateOnly = DateOnly.FromDateTime(date);

                    if (window != null && !window.DayFrequency.ContainsKey(dow))
                        continue;

                    var wh = facility.SportCenter.WorkingHours
                        .Where(w =>
                            IsInDayRange(w.StartDay, w.EndDay, dow) &&
                            w.ValidFrom <= dateOnly &&
                            (w.ValidTo == null || w.ValidTo >= dateOnly))
                        .OrderByDescending(w => w.ValidFrom)
                        .FirstOrDefault();

                    if (wh == null)
                        continue;

                    var slotDuration = facility.Duration;
                    var slotStart = date.Date.Add(wh.OpeningHours.ToTimeSpan());
                    var slotEnd = slotStart.Add(slotDuration);
                    var closeTime = date.Date.Add(wh.CloseingHours.ToTimeSpan());

                    facilityReservations.TryGetValue((facility.Id, dateOnly), out var facilityDay);
                    userReservations.TryGetValue(dateOnly, out var userDay);

                    while (slotEnd <= closeTime)
                    {
                        var startTod = slotStart.TimeOfDay;

                        bool fitsRoutine = window == null ||
                            FeatureBuilder.MinutesFromUsualStart(window, dow, startTod) <= FeatureBuilder.TimeFitToleranceMinutes;

                        if (fitsRoutine)
                        {
                            var startOnly = TimeOnly.FromDateTime(slotStart);
                            var endOnly = TimeOnly.FromDateTime(slotEnd);

                            bool courtOccupied = facilityDay != null &&
                                 facilityDay.Any(r => r.StartTime < endOnly && r.EndTime > startOnly);

                            bool userBusy = userDay != null &&
                                 userDay.Any(r => r.StartTime < endOnly && r.EndTime > startOnly);

                            if (!courtOccupied && !userBusy)
                            {
                                candidates.Add(new TimeSlotCandidate
                                {
                                    FacilityId = facility.Id,
                                    FacilityName = facility.Name ?? string.Empty,
                                    SportCenterId = facility.SportCenterId,
                                    SportCenterName = facility.SportCenter.DisplayName ?? string.Empty,
                                    CityId = facility.SportCenter.CityId,
                                    IsIndoor = facility.IsIndoor,
                                    TurfTypeId = facility.TurfTypeId,
                                    SportIds = sportIds,
                                    StartTime = slotStart,
                                    EndTime = slotEnd,
                                    Price = ComputeSlotPrice(facility, dow, startOnly, slotDuration)
                                });
                            }
                        }

                        slotStart = slotEnd;
                        slotEnd = slotStart.Add(slotDuration);
                    }
                }
            }

            return candidates;
        }

        private async Task<List<RecommendationResult>> GetFallbackRecommendationsAsync(int userId, int topN)
        {
            var homeCityId = await GetUserCityIdAsync(userId);
            var (overallRatings, reviewCounts, globalAverage) = await GetFacilityRatingStatsAsync();

            var popularitySince = DateOnly.FromDateTime(TimeHelper.GetFacilityNow().AddDays(-PopularityLookbackDays));
            var bookingCounts = await _db.Reservations
                .AsNoTracking()
                .Where(r => r.FacilityId != null &&
                    r.ReservationDate >= popularitySince &&
                    r.Status != nameof(CanceledReservationState) &&
                    r.Status != nameof(CanceledWithRefundReservationState) &&
                    r.Status != nameof(CanceledWithoutRefundReservationState))
                .GroupBy(r => r.FacilityId!.Value)
                .Select(g => new { FacilityId = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.FacilityId, x => x.Count);

            var facilities = await _db.Facilities
                .AsNoTracking()
                .Select(f => new { f.Id, CityId = (int?)f.SportCenter!.CityId })
                .ToListAsync();

            if (facilities.Count == 0)
                return new List<RecommendationResult>();

            int maxBookings = bookingCounts.Count > 0 ? bookingCounts.Values.Max() : 0;

            var ranked = facilities
                .Select(f =>
                {
                    overallRatings.TryGetValue(f.Id, out float avgRating);
                    reviewCounts.TryGetValue(f.Id, out int reviewCount);
                    bookingCounts.TryGetValue(f.Id, out int bookings);

                    float smoothedRating = (avgRating * reviewCount + globalAverage * 3f) / (reviewCount + 3f);
                    float popularity = maxBookings > 0 ? (float)bookings / maxBookings : 0f;
                    bool inUserCity = homeCityId.HasValue && f.CityId == homeCityId;

                    float score =
                        FallbackWeightRating * (smoothedRating / 5f) +
                        FallbackWeightPopularity * popularity +
                        FallbackWeightCity * (inUserCity ? 1f : 0f);

                    return new
                    {
                        FacilityId = f.Id,
                        AvgRating = avgRating,
                        ReviewCount = reviewCount,
                        IsPopular = popularity >= 0.5f,
                        InUserCity = inUserCity,
                        Score = Math.Clamp(score, 0f, 1f)
                    };
                })
                .OrderByDescending(x => x.Score)
                .ThenByDescending(x => x.ReviewCount)
                .ToList();

            var shortlist = ranked.Take(Math.Max(topN * 3, topN)).ToList();
            var shortlistIds = shortlist.Select(x => x.FacilityId).ToList();

            var nextFreeSlotPerFacility = (await GetAvailableSlotsAsync(userId, window: null, shortlistIds))
                .GroupBy(s => s.FacilityId)
                .ToDictionary(g => g.Key, g => g.OrderBy(s => s.StartTime).First());

            return shortlist
                .Where(x => nextFreeSlotPerFacility.ContainsKey(x.FacilityId))
                .Take(topN)
                .Select(x =>
                {
                    var slot = nextFreeSlotPerFacility[x.FacilityId];
                    return new RecommendationResult
                    {
                        FacilityId = slot.FacilityId,
                        FacilityName = slot.FacilityName,
                        SportCenterName = slot.SportCenterName,
                        StartTime = slot.StartTime,
                        EndTime = slot.EndTime,
                        Price = slot.Price,
                        Score = x.Score,
                        Reasons = ExplanationBuilder.BuildFallback(x.AvgRating, x.ReviewCount, x.IsPopular, x.InUserCity),
                        IsPersonalized = false
                    };
                })
                .ToList();
        }

        private async Task<int?> GetUserCityIdAsync(int userId)
        {
            return await _db.Users
                .AsNoTracking()
                .Where(u => u.Id == userId)
                .Select(u => (int?)u.CityId)
                .FirstOrDefaultAsync();
        }

        private async Task<(Dictionary<int, float> AvgRatings, Dictionary<int, int> ReviewCounts, float GlobalAverage)>
            GetFacilityRatingStatsAsync()
        {
            var stats = await _db.FacilityReviews
                .AsNoTracking()
                .Where(fr => fr.FacilityId != null)
                .GroupBy(fr => fr.FacilityId!.Value)
                .Select(g => new
                {
                    FacilityId = g.Key,
                    AvgRating = g.Average(fr => (double)fr.RatingNumber),
                    Count = g.Count()
                })
                .ToListAsync();

            int totalReviews = stats.Sum(s => s.Count);
            float globalAverage = totalReviews > 0
                ? (float)(stats.Sum(s => s.AvgRating * s.Count) / totalReviews)
                : 3.5f;

            return (
                stats.ToDictionary(s => s.FacilityId, s => (float)s.AvgRating),
                stats.ToDictionary(s => s.FacilityId, s => s.Count),
                globalAverage);
        }

        private async Task LogRecommendationEventsAsync(int userId, List<RecommendationResult> results)
        {
            var events = results.Select(r => new RecommendationEvent
            {
                UserId = userId,
                FacilityId = r.FacilityId,
                CandidateStart = r.StartTime,
                CandidateEnd = r.EndTime,
                Score = r.Score,
                ExplanationJson = JsonConvert.SerializeObject(r.Reasons),
                WasClicked = false,
                WasBooked = false,
                ShownAt = DateTime.UtcNow
            }).ToList();

            _db.RecommendationEvents.AddRange(events);
            await _db.SaveChangesAsync();
        }

        private static bool IsCompleted(Reservation reservation)
        {
            return reservation.Status == nameof(CompletedReservationState) || reservation.Status == "Completed";
        }

        private static double RecencyWeight(DateOnly reservationDate, DateOnly today)
        {
            int ageDays = Math.Max(0, today.DayNumber - reservationDate.DayNumber);
            return Math.Max(MinRecencyWeight, Math.Pow(0.5, ageDays / RecencyHalfLifeDays));
        }

        private static float RatingWeight(float rating)
        {
            return rating > 0f ? rating / 3f : 1f;
        }

        private static TimeSpan RoundToHalfHour(TimeSpan time)
        {
            return TimeSpan.FromMinutes(Math.Round(time.TotalMinutes / 30.0) * 30.0);
        }

        private static void AddWeight(Dictionary<int, float> weights, int key, float value)
        {
            weights[key] = weights.GetValueOrDefault(key) + value;
        }

        private static Dictionary<int, float> NormalizeToSum(Dictionary<int, float> weights)
        {
            float total = weights.Values.Sum();
            return total > 0
                ? weights.ToDictionary(kv => kv.Key, kv => kv.Value / total)
                : new Dictionary<int, float>();
        }

        private static Dictionary<int, float> NormalizeToMax(Dictionary<int, float> weights)
        {
            float max = weights.Count > 0 ? weights.Values.Max() : 0f;
            return max > 0
                ? weights.ToDictionary(kv => kv.Key, kv => kv.Value / max)
                : new Dictionary<int, float>();
        }

        private static bool IsInDayRange(DayOfWeek startDay, DayOfWeek endDay, DayOfWeek day)
        {
            if (startDay <= endDay)
                return day >= startDay && day <= endDay;

            return day >= startDay || day <= endDay;
        }

        private static decimal ComputeSlotPrice(
            Facility facility, DayOfWeek dow, TimeOnly startTime, TimeSpan duration)
        {
            if (!facility.IsDynamicPricing || !facility.DynamicPrices.Any())
                return facility.StaticPrice ?? 0m;

            var dynamicPrice = facility.DynamicPrices
                .FirstOrDefault(dp =>
                    IsInDayRange(dp.StartDay, dp.EndDay, dow) &&
                    startTime >= dp.StartTime &&
                    startTime < dp.EndTime);

            if (dynamicPrice == null)
                return facility.StaticPrice ?? 0m;

            decimal hours = (decimal)duration.TotalHours;
            return dynamicPrice.Price * hours;
        }
    }
}
