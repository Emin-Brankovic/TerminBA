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
    }
}
