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
    public class CityController : BaseCRUDController<CityResponse,CitySearchObject,CityInsertRequest,CityUpdateRequest>
    {

        public CityController(ICityService cityService) : base(cityService)
        {
          
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<PagedResult<CityResponse>> Get([FromQuery] CitySearchObject? search = null)
        {
            return await base.Get(search);
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override async Task<CityResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public override Task<CityResponse> Create([FromBody] CityInsertRequest request)
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
        public override Task<CityResponse?> Update(int id, [FromBody] CityUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}
