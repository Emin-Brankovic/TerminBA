using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.BackgroundServices
{
    public class RecommendationTrainingHostedService : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<RecommendationTrainingHostedService> _logger;

        public RecommendationTrainingHostedService(
            IServiceScopeFactory scopeFactory,
            ILogger<RecommendationTrainingHostedService> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var modelPath = Path.GetFullPath("MLModels/model.zip");
            bool shouldTrainOnStartup = true;

            if (File.Exists(modelPath))
            {
                var lastModified = File.GetLastWriteTimeUtc(modelPath);
                if (DateTime.UtcNow - lastModified < TimeSpan.FromDays(7))
                {
                    _logger.LogInformation("A recent recommendation model already exists (trained at {Time} UTC). Skipping initial startup training.", lastModified);
                    shouldTrainOnStartup = false;
                }
            }

            if (shouldTrainOnStartup)
            {
                _logger.LogInformation("RecommendationTrainingHostedService started. Model will be trained in the background.");
                await TrainModelAsync();
            }

            // Periodically retrain every 7 days
            using var timer = new PeriodicTimer(TimeSpan.FromDays(7));
            while (!stoppingToken.IsCancellationRequested && await timer.WaitForNextTickAsync(stoppingToken))
            {
                _logger.LogInformation("Running periodic recommendation model training.");
                await TrainModelAsync();
            }
        }

        private async Task TrainModelAsync()
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var recommendationService = scope.ServiceProvider.GetRequiredService<IRecommendationService>();

                var result = await recommendationService.TrainModelAsync();

                if (result.Success)
                {
                    _logger.LogInformation(
                        "Recommendation model trained successfully in background. Accuracy={Acc:F3}, Rows={Rows}",
                        result.Accuracy, result.TrainingRowCount);
                }
                else
                {
                    _logger.LogWarning("Background recommendation model training failed or skipped: {Error}", result.ErrorMessage);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred while training the recommendation model in the background.");
            }
        }
    }
}
