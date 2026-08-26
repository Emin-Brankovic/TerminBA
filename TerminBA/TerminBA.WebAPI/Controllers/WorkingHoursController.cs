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
    public class WorkingHoursController : BaseCRUDController<WorkingHoursResponse, WorkingHoursSearchObject, WorkingHoursInsertRequest, WorkingHoursUpdateRequest>
    {
        public WorkingHoursController(IWorkingHoursService workingHoursService) : base(workingHoursService)
        {
        }

        [HttpPost]
        [Authorize(Roles = "Administrator,Sport center")]
        public override Task<WorkingHoursResponse> Create([FromBody] WorkingHoursInsertRequest request)
        {
            return base.Create(request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Administrator,Sport center")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Administrator,Sport center")]
        public override Task<WorkingHoursResponse?> Update(int id, [FromBody] WorkingHoursUpdateRequest request)
        {
            return base.Update(id, request);
        }
    }
}