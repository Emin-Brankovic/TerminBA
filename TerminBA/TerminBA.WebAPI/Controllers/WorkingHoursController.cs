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
    public class WorkingHoursController : BaseCRUDController<WorkingHoursResponse, WorkingHoursSearchObject, WorkingHoursInsertRequest, WorkingHoursUpdateRequest>
    {
        public WorkingHoursController(IWorkingHoursService workingHoursService) : base(workingHoursService)
        {
        }
    }
}





