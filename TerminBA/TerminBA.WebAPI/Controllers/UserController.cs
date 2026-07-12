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

        [HttpPost("login")]
        public async Task<AuthResponse> Login (UserLoginRequest request)
        {
           return(await _userService.Login(request));
        }

        [HttpGet("profile")]
        public async Task<UserResponse> GetProfile()
        {
            return await _userService.GetProfile();
        }

        [HttpGet("playedMatches")]
        public async Task<int> GetMyPlayedMatches()
        {
            return await _userService.GetMyPlayedMatches();
        }

        [HttpGet("{id}/playedMatches")]
        public async Task<int> GetPlayedMatches(int id)
        {
            return await _userService.GetPlayedMatches(id);
        }
    }
}




