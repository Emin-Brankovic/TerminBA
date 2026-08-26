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
    public class AmenityController : BaseCRUDController<AmenityResponse, AmenitySearchObject, AmenityInsertRequest, AmenityUpdateRequest>
    {
        public AmenityController(IAmenityService amenityService) : base(amenityService)
        {
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public override Task<AmenityResponse> Create([FromBody] AmenityInsertRequest request)
        {
            return base.Create(request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Administrator")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Administrator")]
        public override Task<AmenityResponse?> Update(int id, [FromBody] AmenityUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}


