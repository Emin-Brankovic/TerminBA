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

            using var timer = new PeriodicTimer(TimeSpan.FromMinutes(10));

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

                var today = DateOnly.FromDateTime(DateTime.Now);
                var now = TimeOnly.FromDateTime(DateTime.Now);

                var updated = await context.Reservations
                    .Where(r => r.Status == nameof(ActiveReservationState)
                        && (r.ReservationDate < today
                            || (r.ReservationDate == today && r.EndTime <= now)))
                    .ExecuteUpdateAsync(setters => setters
                        .SetProperty(r => r.Status, nameof(CompletedReservationState)), ct);

                if (updated > 0)
                {
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
