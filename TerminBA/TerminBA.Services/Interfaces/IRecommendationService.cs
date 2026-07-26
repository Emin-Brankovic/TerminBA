using TerminBA.Services.Recommender;

namespace TerminBA.Services.Interfaces
{
    public interface IRecommendationService
    {
        Task<TrainingResult> TrainModelAsync();

        Task<List<RecommendationResult>> GetRecommendationsAsync(int userId, int topN = 5);
    }
}
