using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Interfaces;

namespace TerminBA.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FacilityReviewController : BaseCRUDController<FacilityReviewResponse, FacilityReviewSearchObject, FacilityReviewInsertRequest, FacilityReviewUpdateRequest>
    {
        private readonly IFacilityReviewService _facilityReviewService;

        public FacilityReviewController(IFacilityReviewService facilityReviewService) : base(facilityReviewService)
        {
            this._facilityReviewService = facilityReviewService;
        }

        [HttpGet("averageRating/{id}")]
        public async Task<double> GetAverageRatingAsync(int id)
        {
            return await _facilityReviewService.GetAverageRatingAsync(id);
        }
    }
}
