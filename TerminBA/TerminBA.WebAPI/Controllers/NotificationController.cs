using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Interfaces;

namespace TerminBA.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationController : ControllerBase
    {
        private readonly INotificationService _service;

        public NotificationController(INotificationService service)
        {
            _service = service;
        }

        [HttpGet]
        [Authorize(Roles = "User")]
        public async Task<ActionResult<PagedResult<NotificationResponse>>> Get([FromQuery] NotificationSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpPut("{id}/mark-as-seen")]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> MarkAsSeen(int id, [FromQuery] string type)
        {
            await _service.MarkAsSeenAsync(id, type);
            return Ok();
        }

        [HttpGet("unseen-count")]
        [Authorize(Roles = "User")]
        public async Task<ActionResult<int>> GetUnseenCount()
        {
            return await _service.GetUnseenCountAsync();
        }

        [HttpPut("mark-as-seen-multiple")]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> MarkAsSeenMultiple([FromBody] List<NotificationIdentifier> ids)
        {
            await _service.MarkAsSeenMultipleAsync(ids);
            return Ok();
        }

        [HttpPost("delete-multiple")]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> DeleteMultiple([FromBody] List<NotificationIdentifier> ids)
        {
            await _service.DeleteMultipleAsync(ids);
            return Ok();
        }
    }
}
