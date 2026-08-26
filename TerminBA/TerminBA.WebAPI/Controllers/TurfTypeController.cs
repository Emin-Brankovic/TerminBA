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
    [Authorize]
    public class TurfTypeController : BaseCRUDController<TurfTypeResponse, TurfTypeSearchObject, TurfTypeInsertRequest, TurfTypeUpdateRequest>
    {
        public TurfTypeController(ITurfTypeService turfTypeService) : base(turfTypeService)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<PagedResult<TurfTypeResponse>> Get([FromQuery] TurfTypeSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override async Task<TurfTypeResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public override Task<TurfTypeResponse> Create([FromBody] TurfTypeInsertRequest request)
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
        public override Task<TurfTypeResponse?> Update(int id, [FromBody] TurfTypeUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}


