using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TerminBA.Services.Interfaces;
using TerminBA.Services.Recommender;

namespace TerminBA.WebAPI.Controllers
{
    [Authorize(Roles = "User")]
    [ApiController]
    [Route("api/recommendations")]
    public class RecommendationsController : ControllerBase
    {
        private readonly IRecommendationService _recommendationService;
        private readonly ILogger<RecommendationsController> _logger;

        public RecommendationsController(
            IRecommendationService recommendationService,
            ILogger<RecommendationsController> logger)
        {
            _recommendationService = recommendationService;
            _logger = logger;
        }

        [HttpGet("{userId:int}")]
        [ProducesResponseType(typeof(List<RecommendationResult>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status503ServiceUnavailable)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<List<RecommendationResult>>> GetRecommendations(
            int userId,
            [FromQuery] int topN = 5)
        {
            if (topN < 1 || topN > 20)
                topN = 5;

            List<RecommendationResult> recommendations;

            try
            {
                recommendations = await _recommendationService.GetRecommendationsAsync(userId, topN);
            }
            catch (Exception ex) when (
                ex.Message.Contains("model") || ex.Message.Contains("Model") ||
                ex is InvalidOperationException or FileNotFoundException)
            {
                _logger.LogWarning("Model not trained yet: {Error}", ex.Message);
                return StatusCode(StatusCodes.Status503ServiceUnavailable, new
                {
                    error = "The recommendation model has not been trained yet. Please wait for the background training service to complete."
                });
            }

            return Ok(recommendations);
        }
    }
}
