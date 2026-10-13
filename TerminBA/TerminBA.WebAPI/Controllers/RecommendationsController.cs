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

        [HttpGet]
        [ProducesResponseType(typeof(List<RecommendationResult>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<List<RecommendationResult>>> GetRecommendations(
            [FromQuery] int topN = 5)
        {
            var userIdString = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdString) || !int.TryParse(userIdString, out int userId))
            {
                return Unauthorized("User ID not found in token.");
            }

            if (topN < 1 || topN > 20)
                topN = 5;

            var recommendations = await _recommendationService.GetRecommendationsAsync(userId, topN);

            _logger.LogDebug(
                "Returned {Count} recommendations for user {UserId} (personalized: {Personalized}).",
                recommendations.Count, userId, recommendations.FirstOrDefault()?.IsPersonalized ?? false);

            return Ok(recommendations);
        }
    }
}
