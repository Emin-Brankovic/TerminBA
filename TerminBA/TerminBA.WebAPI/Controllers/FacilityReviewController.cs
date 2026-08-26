using Microsoft.AspNetCore.Authorization;
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

        [Authorize(Roles = "User")]
        [HttpPost]
        public override Task<FacilityReviewResponse> Create([FromBody] FacilityReviewInsertRequest request)
        {
            return base.Create(request);
        }

        [Authorize(Roles = "User")]
        [HttpPut("{id}")]
        public override Task<FacilityReviewResponse?> Update(int id, [FromBody] FacilityReviewUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "User,Sport center")]
        [HttpDelete("{id}")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}
