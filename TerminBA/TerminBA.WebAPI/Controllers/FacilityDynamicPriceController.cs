using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Interfaces;

namespace TerminBA.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FacilityDynamicPriceController : BaseCRUDController<FacilityDynamicPriceResponse, FacilityDynamicPriceSearchObject, FacilityDynamicPriceInsertRequest, FacilityDynamicPriceUpdateRequest>
    {
        private readonly IFacilityDynamicPriceService _facilityDynamicPriceService;

        public FacilityDynamicPriceController(IFacilityDynamicPriceService facilityDynamicPriceService) : base(facilityDynamicPriceService)
        {
            this._facilityDynamicPriceService = facilityDynamicPriceService;
        }

        [HttpGet("selectedDatePrice")]
        public async Task<decimal> DynamicPriceForDate([FromQuery] DynamicPriceForDateRequest request)
        {
            var price = await _facilityDynamicPriceService.DynamicPriceForDateAsync(request);

            return price;
        }

        [Authorize(Roles = "Sport center")]
        [HttpPost]
        public override Task<FacilityDynamicPriceResponse> Create([FromBody] FacilityDynamicPriceInsertRequest request)
        {
            return base.Create(request);
        }

        [Authorize(Roles = "Sport center")]
        [HttpPut("{id}")]
        public override Task<FacilityDynamicPriceResponse?> Update(int id, [FromBody] FacilityDynamicPriceUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Sport center")]
        [HttpDelete("{id}")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }

    }
}

