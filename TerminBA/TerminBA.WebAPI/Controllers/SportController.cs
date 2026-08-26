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

    public class SportController : BaseCRUDController<SportResponse, SportSearchObject, SportInserRequest, SportUpdateRequest>
    {
        public SportController(ISportService sportService) : base(sportService)
        {
        }

        [HttpGet]
        public override async Task<PagedResult<SportResponse>> Get([FromQuery] SportSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public override Task<SportResponse> Create([FromBody] SportInserRequest request)
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
        public override Task<SportResponse?> Update(int id, [FromBody] SportUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}
