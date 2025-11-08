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
        public async Task<PlayRequestResponse> PlayRequestResponse (int id, bool response)
        {
            var playRequest=await _playRequestService.PlayRequestResponse(id, response);

            return playRequest;
        } 


    }
}
