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

    }
}

