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
    public class SkillLevelController : BaseCRUDController<SkillLevelResponse, SkillLevelSearchObject, SkillLevelInsertRequest, SkillLevelUpdateRequest>
    {
        public SkillLevelController(ISkillLevelService service) : base(service)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<PagedResult<SkillLevelResponse>> Get([FromQuery] SkillLevelSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override async Task<SkillLevelResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public override Task<SkillLevelResponse> Create([FromBody] SkillLevelInsertRequest request)
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
        public override Task<SkillLevelResponse?> Update(int id, [FromBody] SkillLevelUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}
