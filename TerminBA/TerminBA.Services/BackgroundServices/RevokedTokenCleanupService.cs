using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using TerminBA.Services.Database;

namespace TerminBA.Services.BackgroundServices
{
    public class RevokedTokenCleanupService : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<RevokedTokenCleanupService> _logger;

        private static readonly TimeSpan CleanupInterval = TimeSpan.FromHours(6);

        public RevokedTokenCleanupService(
            IServiceScopeFactory scopeFactory,
            ILogger<RevokedTokenCleanupService> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            await CleanupExpiredTokensAsync(stoppingToken);

            using var timer = new PeriodicTimer(CleanupInterval);

            while (!stoppingToken.IsCancellationRequested &&
                    await timer.WaitForNextTickAsync(stoppingToken))
            {
                await CleanupExpiredTokensAsync(stoppingToken);
            }
        }

        private async Task CleanupExpiredTokensAsync(CancellationToken ct)
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var context = scope.ServiceProvider.GetRequiredService<TerminBaContext>();

                var now = DateTime.UtcNow;
                var deleted = await context.RevokedTokens
                    .Where(rt => rt.ExpiresAt < now)
                    .ExecuteDeleteAsync(ct);

                if (deleted > 0)
                {
                    _logger.LogInformation(
                        "Cleaned up {Count} expired revoked token entries.", deleted);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to clean up expired revoked tokens.");
            }
        }
    }
}
