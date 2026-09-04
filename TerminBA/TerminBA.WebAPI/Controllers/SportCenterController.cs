using Microsoft.AspNetCore.Authorization;
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

    
        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<AuthResponse> Login(SportCenterLoginRequest request)
        {
            return (await _sportCenterService.Login(request));
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public override Task<SportCenterResponse> Create([FromBody] SportCenterInsertRequest request)
        {
            return base.Create(request);
        }

        [Authorize(Roles = "Sport center")]
        [HttpPut("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            await _sportCenterService.ChangePassword(request);
            return Ok();
        }

        [Authorize(Roles = "Sport center")]
        [HttpGet("getCurrent")]
        public async Task<SportCenterResponse> GetCurrentSportCenter()
        {
            return await _sportCenterService.GetCurrentSportCenter();
        }

        [Authorize(Roles = "Administrator,Sport center")]
        [HttpGet("{id}/withAllWorkingHours")]
        public async Task<SportCenterResponse> GetByIdWithAllWorkingHours(int id)
        {
            return await _sportCenterService.GetByIdWithAllWorkingHoursAsync(id);
        }

        [Authorize(Roles = "Sport center")]
        [HttpPut("gallery")]
        public async Task<SportCenterResponse> UpdateGallery([FromBody] SportCenterGalleryUpdateRequest request)
        {
            return await _sportCenterService.UpdateCurrentGallery(request);
        }

        [HttpGet("searchAvailable")]
        public async Task<PagedResult<SportCenterResponse>> SearchAvailable(
            [FromQuery] SportCenterAvailabilitySearchObject search)
        {
            return await _sportCenterService.SearchAvailableAsync(search);
        }


        [HttpGet("averageRating/{id}")]
        public async Task<double> GetAverageRatingAsync(int id)
        {
            return await _sportCenterService.GetAverageRatingAsync(id);
        }

        [Authorize(Roles = "Sport center")]
        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            await _sportCenterService.Logout();
            return Ok();
        }
    }
}