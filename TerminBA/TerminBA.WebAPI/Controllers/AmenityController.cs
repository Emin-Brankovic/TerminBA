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

        [HttpGet]
        [AllowAnonymous]
        public override async Task<PagedResult<AmenityResponse>> Get([FromQuery] AmenitySearchObject? search = null)
        {
            return await base.Get(search);
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override async Task<AmenityResponse?> GetById(int id)
        {
            return await base.GetById(id);
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


