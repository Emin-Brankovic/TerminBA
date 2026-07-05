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
    public class PlayRequestController : BaseCRUDController<PlayRequestResponse, PlayRequestSearchObject, PlayRequestInsertRequest, PlayRequestUpdateRequest>
    {
        private readonly IPlayRequestService _playRequestService;

        public PlayRequestController(IPlayRequestService playRequestService) : base(playRequestService)
        {
            this._playRequestService = playRequestService;
        }


        [HttpPut("requestResponse/{id}")]
        public async Task<PlayRequestResponse> RespondToPlayRequest(int id, bool response)
        {
            var playRequest=await _playRequestService.RespondToPlayRequestAsync(id, response);

            return playRequest;
        }


        [HttpPut("cancleRequest/{id}")]
        public async Task<PlayRequestResponse> CancleRequest (int id)
        {
            var playRequest = await _playRequestService.CancelAsync(id);

            return playRequest;
        }

        [HttpGet("received/unseen-count")]
        [Microsoft.AspNetCore.Authorization.Authorize]
        public async Task<int> GetUnseenRequestsCount()
        {
            return await _playRequestService.GetUnseenRequestsCountAsync();

        }

        [HttpPost("{id}/mark-seen")]
        [Microsoft.AspNetCore.Authorization.Authorize]
        public async Task<PlayRequestResponse> MarkRequestAsSeen(int id)
        {
           return await _playRequestService.MarkRequestAsSeenAsync(id);
        }

        [HttpGet("sent/unseen-count")]
        [Microsoft.AspNetCore.Authorization.Authorize]
        public async Task<int> GetUnseenResponsesCount()
        {
           return await _playRequestService.GetUnseenResponsesCountAsync();
        }

        [HttpPost("{id}/mark-response-seen")]
        [Microsoft.AspNetCore.Authorization.Authorize]
        public async Task<PlayRequestResponse> MarkResponseAsSeen(int id)
        {
            return await _playRequestService.MarkResponseAsSeenAsync(id);
        }
    }
}
