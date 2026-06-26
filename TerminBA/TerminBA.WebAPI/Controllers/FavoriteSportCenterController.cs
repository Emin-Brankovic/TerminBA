using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TerminBA.Models.Model;
using TerminBA.Models.Requests;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Interfaces;
using System.Threading.Tasks;

namespace TerminBA.WebAPI.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class FavoriteSportCenterController : BaseCRUDController<FavoriteSportCenterResponse, FavoriteSportCenterSearchObject, FavoriteSportCenterInsertRequest, object>
    {
        private readonly IFavoriteSportCenterService _service;

        public FavoriteSportCenterController(IFavoriteSportCenterService service) : base(service)
        {
            _service = service;
        }
    }
}
