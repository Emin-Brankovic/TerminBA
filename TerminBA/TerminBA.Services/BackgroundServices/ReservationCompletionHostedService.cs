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


                var reservationsQuery = context.Reservations
                    .Where(r => r.Status == nameof(ActiveReservationState)
                        && (r.ReservationDate < today
                            || (r.ReservationDate == today && r.StartTime <= timeNow)));

                var reservationIdsToComplete = await reservationsQuery.Select(r => r.Id).ToListAsync(ct);

                if (reservationIdsToComplete.Any())
                {
                    // 1. Expire pending play requests
                    await context.PlayRequests
                        .Where(pr => pr.PlayRequestState == nameof(PendingPlayRequestState) && pr.Post != null && reservationIdsToComplete.Contains(pr.Post.ReservationId))
                        .ExecuteUpdateAsync(setters => setters
                            .SetProperty(pr => pr.PlayRequestState, nameof(ExpiredPlayRequestState))
                            .SetProperty(pr => pr.Reason, "The reservation began before the post owner evaluated your request.")
                            .SetProperty(pr => pr.DateOfResponse, DateTime.UtcNow), ct);

                    // 2. Finish posts
                    await context.Posts
                        .Where(p => reservationIdsToComplete.Contains(p.ReservationId))
                        .ExecuteUpdateAsync(setters => setters
                            .SetProperty(p => p.PostState, nameof(FinishedPostState)), ct);

                    // 3. Complete reservations
                    var updated = await context.Reservations
                        .Where(r => reservationIdsToComplete.Contains(r.Id))
                        .ExecuteUpdateAsync(setters => setters
                            .SetProperty(r => r.Status, nameof(CompletedReservationState)), ct);

                    _logger.LogInformation("Auto-completed {Count} reservations, and transitioned related posts and requests.", updated);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to auto-complete finished reservations.");
            }
        }

    }
}
