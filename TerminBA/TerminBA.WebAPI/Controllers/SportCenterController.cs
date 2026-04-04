using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Interfaces;
using TerminBA.Services.Service;

namespace TerminBA.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SportCenterController : BaseCRUDController<SportCenterResponse, SportCenterSearchObject, SportCenterInsertRequest, SportCenterUpdateRequest>
    {
        private readonly ISportCenterService _sportCenterService;

        public SportCenterController(ISportCenterService sportCenterService) : base(sportCenterService)
        {
            this._sportCenterService = sportCenterService;
        }


        [HttpPost("login")]
        public async Task<AuthResponse> Login(SportCenterLoginRequest request)
        {
            return (await _sportCenterService.Login(request));
        }
    }
}