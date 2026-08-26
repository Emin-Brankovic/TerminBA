using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Interfaces;

namespace TerminBA.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : BaseCRUDController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService) : base(userService)
        {
            _userService = userService;
        }

        [Authorize(Roles = "User,Administrator")]
        [HttpPut("{id}")]
        public override Task<UserResponse?> Update(int id, [FromBody] UserUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<AuthResponse> Login (UserLoginRequest request)
        {
           return(await _userService.Login(request));
        }

        [HttpPost]
        [AllowAnonymous]
        public override async Task<UserResponse> Create([FromBody] UserInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "User,Administrator")]
        [HttpGet("profile")]
        public async Task<UserResponse> GetProfile()
        {
            return await _userService.GetProfile();
        }

        [Authorize(Roles = "User")]
        [HttpGet("playedMatches")]
        public async Task<int> GetMyPlayedMatches()
        {
            return await _userService.GetMyPlayedMatches();
        }

        [Authorize(Roles = "User")]
        [HttpGet("{id}/playedMatches")]
        public async Task<int> GetPlayedMatches(int id)
        {
            return await _userService.GetPlayedMatches(id);
        }

        [Authorize(Roles = "User,Administrator")]
        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            await _userService.Logout();
            return Ok();
        }

        [Authorize(Roles = "User")]
        [HttpPost("changePassword")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            await _userService.ChangePassword(request);
            return Ok();
        }
    }
}




