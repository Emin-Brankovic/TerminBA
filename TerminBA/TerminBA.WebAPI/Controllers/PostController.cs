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
    public class PostController : BaseCRUDController<PostResponse, PostSearchObject, PostInsertRequest, PostUpdateRequest>
    {
        private readonly IPostService _postService;

        public PostController(IPostService postService) : base(postService)
        {
            this._postService = postService;
        }

        [HttpPut("closePost/{id}")]
        public async Task<PostResponse> ClosePost(int id)
        {
            var post = await _postService.ClosePost(id);

            return post;
        }

        [HttpPut("reopenPost/{id}")]
        public async Task<PostResponse> ReopenPost(int id)
        {
            var post = await _postService.ReopenPost(id);

            return post;
        }
    }
}