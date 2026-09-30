using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//using EasyNetQ.Logging;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using TerminBA.Services.Database;
using TerminBA.Services.ReservationStateMachine;
using TerminBA.Services.Helpers;
using TerminBA.Services.PlayRequestStateMachine;
using TerminBA.Services.PostStateMachine;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.BackgroundServices
{
    public class ReservationCompletionHostedService : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<ReservationCompletionHostedService> _logger;

        public ReservationCompletionHostedService(
            IServiceScopeFactory scopeFactory,
            ILogger<ReservationCompletionHostedService> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            await CompleteFinishedReservationsAsync(stoppingToken);

            using var timer = new PeriodicTimer(TimeSpan.FromMinutes(2));

            while (!stoppingToken.IsCancellationRequested &&
                    await timer.WaitForNextTickAsync(stoppingToken))
            {
                await CompleteFinishedReservationsAsync(stoppingToken);
            }
        }

        private async Task CompleteFinishedReservationsAsync(CancellationToken ct)
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var context = scope.ServiceProvider.GetRequiredService<TerminBaContext>();

                var now = TimeHelper.GetFacilityNow();
                var today = DateOnly.FromDateTime(now);
                var timeNow = TimeOnly.FromDateTime(now);


                // Process Started Reservations (Expire Play Requests & Finish Posts)
                var startedReservationsQuery = context.Reservations
                    .Where(r => r.Status == nameof(ActiveReservationState)
                        && (r.ReservationDate < today
                            || (r.ReservationDate == today && r.StartTime <= timeNow)));

                var startedReservationIds = await startedReservationsQuery.Select(r => r.Id).ToListAsync(ct);

                if (startedReservationIds.Any())
                {
                    var notificationsHub = scope.ServiceProvider.GetService<INotificationsHubService>();
                    
                    var requestsToExpire = await context.PlayRequests
                        .Where(pr => pr.PlayRequestState == nameof(PendingPlayRequestState) && pr.Post != null && startedReservationIds.Contains(pr.Post.ReservationId))
                        .Select(pr => new 
                        {
                            pr.Id,
                            pr.PostId,
                            pr.RequesterId,
                            PostOwnerId = pr.Post!.Reservation!.UserId,
                            PostOwnerFirstName = pr.Post.Reservation.User!.FirstName,
                            PostOwnerLastName = pr.Post.Reservation.User.LastName
                        })
                        .ToListAsync(ct);

                    var expiredRequestsCount = await context.PlayRequests
                        .Where(pr => pr.PlayRequestState == nameof(PendingPlayRequestState) && pr.Post != null && startedReservationIds.Contains(pr.Post.ReservationId))
                        .ExecuteUpdateAsync(setters => setters
                            .SetProperty(pr => pr.PlayRequestState, nameof(ExpiredPlayRequestState))
                            .SetProperty(pr => pr.Reason, "The reservation began before the post owner evaluated your request.")
                            .SetProperty(pr => pr.DateOfResponse, DateTime.UtcNow), ct);

                    var finishedPostsCount = await context.Posts
                        .Where(p => p.PostState != nameof(FinishedPostState) && startedReservationIds.Contains(p.ReservationId))
                        .ExecuteUpdateAsync(setters => setters
                            .SetProperty(p => p.PostState, nameof(FinishedPostState)), ct);

                    if (expiredRequestsCount > 0 || finishedPostsCount > 0)
                    {
                        _logger.LogInformation("Transitioned {PostCount} posts and {RequestCount} requests for started reservations.", finishedPostsCount, expiredRequestsCount);
                    }

                    if (notificationsHub != null && requestsToExpire.Any())
                    {
                        var nowStr = DateTime.UtcNow.ToString("o");
                        foreach (var req in requestsToExpire)
                        {
                            var ownerName = req.PostOwnerId != null ? $"{req.PostOwnerFirstName} {req.PostOwnerLastName}" : "A user";
                            var payload = new
                            {
                                type = "join_request_responded",
                                requestId = req.Id,
                                postId = req.PostId,
                                isAccepted = false,
                                reason = "The reservation began before the post owner evaluated your request.",
                                fromUserId = req.PostOwnerId,
                                fromUserDisplayName = ownerName,
                                respondedAt = nowStr
                            };
                            await notificationsHub.SendJoinRequestRespondedNotificationAsync(req.RequesterId, payload);
                        }
                    }
                }

                // Process Ended Reservations (Complete Reservations)
                var endedReservationsQuery = context.Reservations
                    .Where(r => r.Status == nameof(ActiveReservationState)
                        && (r.ReservationDate < today
                            || (r.ReservationDate == today && r.EndTime <= timeNow)));

                var endedReservationIds = await endedReservationsQuery.Select(r => r.Id).ToListAsync(ct);

                if (endedReservationIds.Any())
                {
                    var updated = await context.Reservations
                        .Where(r => endedReservationIds.Contains(r.Id))
                        .ExecuteUpdateAsync(setters => setters
                            .SetProperty(r => r.Status, nameof(CompletedReservationState))
                            .SetProperty(r => r.CompletedAt, DateTime.UtcNow), ct);

                    _logger.LogInformation("Auto-completed {Count} reservations.", updated);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to auto-complete finished reservations.");
            }
        }

    }
}
