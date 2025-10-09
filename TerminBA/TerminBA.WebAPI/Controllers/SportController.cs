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
        [Authorize(Roles = "Administrator")]
        public override async Task<PagedResult<SportResponse>> Get([FromQuery] SportSearchObject? search = null)
        {
            return await base.Get(search);
        }
    }
}
