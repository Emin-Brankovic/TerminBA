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
    public class TurfTypeController : BaseCRUDController<TurfTypeResponse, TurfTypeSearchObject, TurfTypeInsertRequest, TurfTypeUpdateRequest>
    {
        public TurfTypeController(ITurfTypeService turfTypeService) : base(turfTypeService)
        {
        }
    }
}


