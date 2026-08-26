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
    public class FacilityController : BaseCRUDController<FacilityResponse, FacilitySearchObject, FacilityInsertRequest, FacilityUpdateRequest>
    {
        private readonly IFacilityService _facilityService;

        public FacilityController(IFacilityService facilityService) : base(facilityService)
        {
            this._facilityService = facilityService;
        }

        [HttpGet("facilityTimeSlots/{id}")]
        public async Task<List<FacilityTimeSlot>> FacilityTimeSlots(int id,DateOnly datePicked)
        {
            var slots=await _facilityService.GetFacilityTimeSlotAsync(id,datePicked);

            return slots;
        }

        [Authorize(Roles = "Sport center")]
        [HttpPost]
        public override Task<FacilityResponse> Create([FromBody] FacilityInsertRequest request)
        {
            return base.Create(request);
        }

        [Authorize(Roles = "Sport center")]
        [HttpPut("{id}")]
        public override Task<FacilityResponse?> Update(int id, [FromBody] FacilityUpdateRequest request)
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