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
    public class SportCenterController : BaseCRUDController<SportCenterResponse, SportCenterSearchObject, SportCenterInsertRequest, SportCenterUpdateRequest>
    {
        public SportCenterController(ISportCenterService sportCenterService) : base(sportCenterService)
        {
        }
    }
}




