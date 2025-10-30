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
    public class UserReviewController : BaseCRUDController<UserReviewResponse, UserReviewSearchObject, UserReviewInsertRequest, UserReviewUpdateRequest>
    {
        public UserReviewController(IUserReviewService userReviewService) : base(userReviewService)
        {
        }
    }
}
