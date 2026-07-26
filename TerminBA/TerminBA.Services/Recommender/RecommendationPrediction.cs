using Microsoft.ML.Data;

namespace TerminBA.Services.Recommender
{
    public class RecommendationPrediction
    {
        [ColumnName("PredictedLabel")]
        public bool WillBook { get; set; }

        public float Probability { get; set; }

        public float Score { get; set; }
    }
}
