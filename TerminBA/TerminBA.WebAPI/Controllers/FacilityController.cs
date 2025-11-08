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
    }
}





