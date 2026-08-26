using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.ML;
using Microsoft.ML;
using Microsoft.ML.Trainers.FastTree;
using Newtonsoft.Json;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;
using TerminBA.Services.Recommender;
using TerminBA.Services.ReservationStateMachine;

namespace TerminBA.Services.Service
{
    public class RecommendationService : IRecommendationService
    {
        private readonly TerminBaContext _db;
        private readonly MLContext _mlContext;
        private readonly PredictionEnginePool<RecommendationInput, RecommendationPrediction> _pool;

        private const string ModelPath = "MLModels/model.zip";
        private const string ModelName = "RecommenderModel";
        private const int CandidateDaysAhead = 14;

        public RecommendationService(
            TerminBaContext db,
            PredictionEnginePool<RecommendationInput, RecommendationPrediction> pool)
        {
            _db = db;
            _mlContext = new MLContext(seed: 0);
            _pool = pool;
        }

        public async Task<TrainingResult> TrainModelAsync()
        {
            try
            {
                var trainingRows = await BuildTrainingDatasetAsync();

                if (trainingRows.Count < 10)
                {
                    return new TrainingResult
                    {
                        Success = false,
                        ErrorMessage = $"Not enough training data: {trainingRows.Count} rows (minimum 10 required). " +
                                       "Make sure users have completed reservations and written facility reviews.",
                        TrainedAt = DateTime.UtcNow
                    };
                }

                IDataView data = _mlContext.Data.LoadFromEnumerable(trainingRows);
                var split = _mlContext.Data.TrainTestSplit(data, testFraction: 0.2, seed: 42);

                var pipeline = _mlContext.Transforms
                    .Concatenate("Features",
                        nameof(RecommendationInput.SportTypeMatch),
                        nameof(RecommendationInput.FacilityAvgUserRating),
                        nameof(RecommendationInput.FacilityAvgOverallRating),
                        nameof(RecommendationInput.PreviouslyBookedFacility),
                        nameof(RecommendationInput.PriceDiffFromUserAvg),
                        nameof(RecommendationInput.FacilityBookingFrequency),
                        nameof(RecommendationInput.TimeWindowFitScore))
                    .Append(_mlContext.Transforms.NormalizeMinMax("Features"))
                    .Append(_mlContext.BinaryClassification.Trainers.FastTree(
                        labelColumnName: "Label",
                        featureColumnName: "Features",
                        numberOfLeaves: 20,
                        numberOfTrees: 100,
                        minimumExampleCountPerLeaf: 1));

                var model = pipeline.Fit(split.TrainSet);
                var metrics = _mlContext.BinaryClassification.Evaluate(
                    model.Transform(split.TestSet));

                Directory.CreateDirectory(Path.GetDirectoryName(ModelPath)!);
                _mlContext.Model.Save(model, data.Schema, ModelPath);

                return new TrainingResult
                {
                    Success = true,
                    Accuracy = metrics.Accuracy,
                    AreaUnderRocCurve = metrics.AreaUnderRocCurve,
                    F1Score = metrics.F1Score,
                    TrainingRowCount = trainingRows.Count,
                    TrainedAt = DateTime.UtcNow
                };
            }
            catch (Exception ex)
            {
                return new TrainingResult
                {
                    Success = false,
                    ErrorMessage = ex.Message,
                    TrainedAt = DateTime.UtcNow
                };
            }
        }

        public async Task<List<RecommendationResult>> GetRecommendationsAsync(int userId, int topN = 5)
        {
            var window = await DeriveUserTimeWindowAsync(userId);

            if (!window.HasEnoughHistory)
            {
                return await GetFallbackRecommendationsAsync(topN);
            }

            var candidateSlots = await GetCandidateSlotsAsync(window);

            if (candidateSlots.Count == 0)
                return new List<RecommendationResult>();

            var userProfile = await BuildUserProfileAsync(userId);

            var results = new List<RecommendationResult>();

            foreach (var slot in candidateSlots)
            {
                var input = FeatureBuilder.Build(userProfile, slot, window);

                RecommendationPrediction prediction;
                try
                {
                    prediction = _pool.Predict(modelName: ModelName, example: input);
                }
                catch
                {
                    return new List<RecommendationResult>();
                }

                var reasons = ExplanationBuilder.Build(input, userProfile, slot, window);

                results.Add(new RecommendationResult
                {
                    FacilityId = slot.FacilityId,
                    FacilityName = slot.FacilityName,
                    SportCenterName = slot.SportCenterName,
                    StartTime = slot.StartTime,
                    EndTime = slot.EndTime,
                    Price = slot.Price,
                    Score = prediction.Probability,
                    Reasons = reasons,
                    IsPersonalized = true
                });
            }

            var topResults = results
                .OrderByDescending(r => r.Score)
                .Take(topN)
                .ToList();

            await LogRecommendationEventsAsync(userId, topResults);

            return topResults;
        }

        private async Task<UserTimeWindow> DeriveUserTimeWindowAsync(int userId)
        {
            var reservations = await _db.Reservations
                .Where(r => r.UserId == userId
                    && (r.Status == "CompletedReservationState" || r.Status == "Completed"))
                .ToListAsync();

            if (reservations.Count < 3)
                return new UserTimeWindow { HasEnoughHistory = false };

            var preferredDays = reservations
                .GroupBy(r => r.ReservationDate.DayOfWeek)
                .OrderByDescending(g => g.Count())
                .Take(2)
                .Select(g => g.Key)
                .ToList();

            var startTimes = reservations
                .Select(r => r.StartTime.ToTimeSpan())
                .OrderBy(t => t)
                .ToList();

            var endTimes = reservations
                .Select(r => r.EndTime.ToTimeSpan())
                .OrderBy(t => t)
                .ToList();

            var medianStart = startTimes[startTimes.Count / 2];
            var medianEnd = endTimes[endTimes.Count / 2];

            return new UserTimeWindow
            {
                PreferredDays = preferredDays,
                MedianStart = medianStart,
                PreferredStart = medianStart.Add(TimeSpan.FromMinutes(-30)),
                PreferredEnd = medianEnd.Add(TimeSpan.FromMinutes(30)),
                HasEnoughHistory = true
            };
        }

        private async Task<List<TimeSlotCandidate>> GetCandidateSlotsAsync(UserTimeWindow window)
        {
            var facilities = await _db.Facilities
                .Include(f => f.SportCenter)
                    .ThenInclude(sc => sc.WorkingHours)
                .Include(f => f.AvailableSports)
                .Include(f => f.DynamicPrices)
                .ToListAsync();

            var today = DateTime.Today;
            var windowStart = DateOnly.FromDateTime(today.AddDays(1));
            var windowEnd = DateOnly.FromDateTime(today.AddDays(CandidateDaysAhead));
            var facilityIds = facilities.Select(f => f.Id).ToList();

            var activeReservations = await _db.Reservations
                .Where(r =>
                    r.FacilityId != null &&
                    facilityIds.Contains(r.FacilityId!.Value) &&
                    r.ReservationDate >= windowStart &&
                    r.ReservationDate <= windowEnd &&
                    r.Status != nameof(CanceledReservationState) &&
                    r.Status != nameof(CanceledWithRefundReservationState) &&
                    r.Status != nameof(CanceledWithoutRefundReservationState))
                .Select(r => new
                {
                    FacilityId = r.FacilityId!.Value,
                    r.ReservationDate,
                    r.StartTime,
                    r.EndTime
                })
                .ToListAsync();

            var reservationLookup = activeReservations
                .GroupBy(r => (r.FacilityId, r.ReservationDate))
                .ToDictionary(g => g.Key, g => g.ToList());

            var candidates = new List<TimeSlotCandidate>();

            foreach (var facility in facilities)
            {
                for (int dayOffset = 1; dayOffset <= CandidateDaysAhead; dayOffset++)
                {
                    var date = today.AddDays(dayOffset);
                    var dow = date.DayOfWeek;

                    if (!window.PreferredDays.Contains(dow))
                        continue;

                    var wh = facility.SportCenter?.WorkingHours.FirstOrDefault(w =>
                        IsInDayRange(w.StartDay, w.EndDay, dow) &&
                        (w.ValidTo == null || w.ValidTo >= DateOnly.FromDateTime(date)));

                    if (wh == null)
                        continue;

                    var slotDuration = facility.Duration;
                    var slotStart = date.Date.Add(wh.OpeningHours.ToTimeSpan());
                    var slotEnd = slotStart.Add(slotDuration);
                    var closeTime = date.Date.Add(wh.CloseingHours.ToTimeSpan());

                    var dateOnly = DateOnly.FromDateTime(date);
                    reservationLookup.TryGetValue((facility.Id, dateOnly), out var dayReservations);

                    while (slotEnd <= closeTime)
                    {
                        var startTod = slotStart.TimeOfDay;

                        if (startTod >= window.PreferredStart && startTod <= window.PreferredEnd)
                        {
                            var startOnly = TimeOnly.FromDateTime(slotStart);
                            var endOnly = TimeOnly.FromDateTime(slotEnd);

                            bool isOccupied = dayReservations != null &&
                                dayReservations.Any(r => r.StartTime < endOnly && r.EndTime > startOnly);

                            if (!isOccupied)
                            {
                                decimal price = ComputeSlotPrice(facility, dow, startOnly, slotDuration);

                                candidates.Add(new TimeSlotCandidate
                                {
                                    FacilityId = facility.Id,
                                    FacilityName = facility.Name ?? string.Empty,
                                    SportCenterName = facility.SportCenter?.DisplayName ?? string.Empty,
                                    SportIds = facility.AvailableSports.Select(s => s.Id).ToList(),
                                    StartTime = slotStart,
                                    EndTime = slotEnd,
                                    Price = price
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

        private async Task<UserProfile> BuildUserProfileAsync(int userId)
        {
            var reservations = await _db.Reservations
                .Where(r => r.UserId == userId &&
                    r.Status != "CanceledReservationState" &&
                    r.Status != "CanceledWithRefundReservationState" &&
                    r.Status != "CanceledWithoutRefundReservationState")
                .ToListAsync();

            int? mostBookedSportId = reservations
                .Where(r => r.ChosenSportId.HasValue)
                .GroupBy(r => r.ChosenSportId!.Value)
                .OrderByDescending(g => g.Count())
                .Select(g => (int?)g.Key)
                .FirstOrDefault();

            decimal avgPrice = reservations.Count > 0
                ? reservations.Average(r => r.Price)
                : 0m;

            var bookingCount = reservations
                .Where(r => r.FacilityId.HasValue)
                .GroupBy(r => r.FacilityId!.Value)
                .ToDictionary(g => g.Key, g => g.Count());

            var userRatings = await _db.FacilityReviews
                .Where(fr => fr.UserId == userId)
                .GroupBy(fr => fr.FacilityId!.Value)
                .Select(g => new { FacilityId = g.Key, AvgRating = (float)g.Average(fr => fr.RatingNumber) })
                .ToDictionaryAsync(x => x.FacilityId, x => x.AvgRating);

            var overallRatings = await _db.FacilityReviews
                .GroupBy(fr => fr.FacilityId!.Value)
                .Select(g => new { FacilityId = g.Key, AvgRating = (float)g.Average(fr => fr.RatingNumber) })
                .ToDictionaryAsync(x => x.FacilityId, x => x.AvgRating);

            return new UserProfile
            {
                UserId = userId,
                MostBookedSportId = mostBookedSportId,
                AveragePaidPrice = avgPrice,
                BookingCountPerFacility = bookingCount,
                UserRatingPerFacility = userRatings,
                OverallRatingPerFacility = overallRatings
            };
        }

        private async Task<List<RecommendationInput>> BuildTrainingDatasetAsync()
        {
            var completedReservations = await _db.Reservations
                .Include(r => r.Facility)
                    .ThenInclude(f => f!.AvailableSports)
                .Where(r => r.Status == "CompletedReservationState" || r.Status == "Completed")
                .ToListAsync();

            var allReviews = await _db.FacilityReviews.ToListAsync();

            var rows = new List<RecommendationInput>();

            var userIds = completedReservations
                .Where(r => r.UserId.HasValue)
                .Select(r => r.UserId!.Value)
                .Distinct()
                .ToList();

            foreach (var uid in userIds)
            {
                var userReservations = completedReservations
                    .Where(r => r.UserId == uid)
                    .ToList();

                if (userReservations.Count < 2) continue;

                var profile = BuildProfileFromReservations(uid, userReservations, allReviews);
                var window = DeriveWindowFromReservations(userReservations);

                if (!window.HasEnoughHistory) continue;

                foreach (var res in userReservations)
                {
                    if (!res.FacilityId.HasValue) continue;

                    var facilityId = res.FacilityId.Value;
                    var sportIds = res.Facility?.AvailableSports.Select(s => s.Id).ToList() ?? new();
                    var slotStart = res.ReservationDate.ToDateTime(res.StartTime);

                    var candidate = new TimeSlotCandidate
                    {
                        FacilityId = facilityId,
                        FacilityName = res.Facility?.Name ?? string.Empty,
                        SportIds = sportIds,
                        StartTime = slotStart,
                        EndTime = res.ReservationDate.ToDateTime(res.EndTime),
                        Price = res.Price
                    };

                    var input = FeatureBuilder.Build(profile, candidate, window);

                    var userRating = allReviews
                        .FirstOrDefault(fr => fr.UserId == uid && fr.FacilityId == facilityId);

                    input.Booked = true;
                    rows.Add(input);

                    var unvisitedFacilityIds = completedReservations
                        .Where(r => r.FacilityId.HasValue && r.FacilityId != facilityId)
                        .Select(r => r.FacilityId!.Value)
                        .Distinct()
                        .Except(userReservations.Where(x => x.FacilityId.HasValue).Select(x => x.FacilityId!.Value))
                        .Take(2)
                        .ToList();

                    foreach (var negFacId in unvisitedFacilityIds)
                    {
                        var negCandidate = new TimeSlotCandidate
                        {
                            FacilityId = negFacId,
                            FacilityName = string.Empty,
                            SportIds = completedReservations
                                .FirstOrDefault(r => r.FacilityId == negFacId)
                                ?.Facility?.AvailableSports.Select(s => s.Id).ToList() ?? new(),
                            StartTime = slotStart,
                            EndTime = slotStart.AddHours(1),
                            Price = profile.AveragePaidPrice
                        };

                        var negInput = FeatureBuilder.Build(profile, negCandidate, window);
                        negInput.Booked = false;
                        rows.Add(negInput);
                    }
                }
            }

            return rows;
        }
        private async Task<List<RecommendationResult>> GetFallbackRecommendationsAsync(int topN)
        {
            var facilityRatings = await _db.FacilityReviews
                .GroupBy(fr => fr.FacilityId!.Value)
                .Select(g => new
                {
                    FacilityId = g.Key,
                    AvgRating = (float)g.Average(fr => fr.RatingNumber),
                    ReviewCount = g.Count()
                })
                .OrderByDescending(x => x.AvgRating)
                .ThenByDescending(x => x.ReviewCount)
                .Take(topN)
                .ToListAsync();

            if (!facilityRatings.Any())
            {
                var allFacilities = await _db.Facilities
                    .Include(f => f.SportCenter)
                    .Take(topN)
                    .ToListAsync();

                return allFacilities.Select(f => new RecommendationResult
                {
                    FacilityId = f.Id,
                    FacilityName = f.Name ?? string.Empty,
                    SportCenterName = f.SportCenter?.DisplayName ?? string.Empty,
                    StartTime = DateTime.UtcNow,
                    EndTime = DateTime.UtcNow.Add(f.Duration),
                    Price = f.StaticPrice ?? 0m,
                    Score = 0f,
                    Reasons = ExplanationBuilder.BuildFallback(0f),
                    IsPersonalized = false
                }).ToList();
            }

            var facilityIds = facilityRatings.Select(x => x.FacilityId).ToList();

            var facilities = await _db.Facilities
                .Include(f => f.SportCenter)
                .Where(f => facilityIds.Contains(f.Id))
                .ToListAsync();

            return facilityRatings.Select(rating =>
            {
                var facility = facilities.FirstOrDefault(f => f.Id == rating.FacilityId);
                return new RecommendationResult
                {
                    FacilityId = rating.FacilityId,
                    FacilityName = facility?.Name ?? string.Empty,
                    SportCenterName = facility?.SportCenter?.DisplayName ?? string.Empty,
                    StartTime = DateTime.UtcNow,
                    EndTime = DateTime.UtcNow.Add(facility?.Duration ?? TimeSpan.FromHours(1)),
                    Price = facility?.StaticPrice ?? 0m,
                    Score = rating.AvgRating / 5f,
                    Reasons = ExplanationBuilder.BuildFallback(rating.AvgRating),
                    IsPersonalized = false
                };
            }).ToList();
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
            return dynamicPrice.PricePerHour * hours;
        }

        private static UserProfile BuildProfileFromReservations(
            int userId,
            List<Reservation> userReservations,
            List<FacilityReview> allReviews)
        {
            int? mostBookedSportId = userReservations
                .Where(r => r.ChosenSportId.HasValue)
                .GroupBy(r => r.ChosenSportId!.Value)
                .OrderByDescending(g => g.Count())
                .Select(g => (int?)g.Key)
                .FirstOrDefault();

            decimal avgPrice = userReservations.Count > 0
                ? userReservations.Average(r => r.Price)
                : 0m;

            var bookingCount = userReservations
                .Where(r => r.FacilityId.HasValue)
                .GroupBy(r => r.FacilityId!.Value)
                .ToDictionary(g => g.Key, g => g.Count());

            var userRatings = allReviews
                .Where(fr => fr.UserId == userId && fr.FacilityId.HasValue)
                .GroupBy(fr => fr.FacilityId!.Value)
                .ToDictionary(g => g.Key, g => (float)g.Average(fr => fr.RatingNumber));

            var overallRatings = allReviews
                .Where(fr => fr.FacilityId.HasValue)
                .GroupBy(fr => fr.FacilityId!.Value)
                .ToDictionary(g => g.Key, g => (float)g.Average(fr => fr.RatingNumber));

            return new UserProfile
            {
                UserId = userId,
                MostBookedSportId = mostBookedSportId,
                AveragePaidPrice = avgPrice,
                BookingCountPerFacility = bookingCount,
                UserRatingPerFacility = userRatings,
                OverallRatingPerFacility = overallRatings
            };
        }

        private static UserTimeWindow DeriveWindowFromReservations(List<Reservation> reservations)
        {
            if (reservations.Count < 3)
                return new UserTimeWindow { HasEnoughHistory = false };

            var preferredDays = reservations
                .GroupBy(r => r.ReservationDate.DayOfWeek)
                .OrderByDescending(g => g.Count())
                .Take(2)
                .Select(g => g.Key)
                .ToList();

            var startTimes = reservations
                .Select(r => r.StartTime.ToTimeSpan())
                .OrderBy(t => t)
                .ToList();

            var endTimes = reservations
                .Select(r => r.EndTime.ToTimeSpan())
                .OrderBy(t => t)
                .ToList();

            var medianStart = startTimes[startTimes.Count / 2];
            var medianEnd = endTimes[endTimes.Count / 2];

            return new UserTimeWindow
            {
                PreferredDays = preferredDays,
                MedianStart = medianStart,
                PreferredStart = medianStart.Add(TimeSpan.FromMinutes(-30)),
                PreferredEnd = medianEnd.Add(TimeSpan.FromMinutes(30)),
                HasEnoughHistory = true
            };
        }
    }
}
