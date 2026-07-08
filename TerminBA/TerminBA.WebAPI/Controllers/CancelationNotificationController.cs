using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Interfaces;

namespace TerminBA.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CancelationNotificationController : BaseCRUDController<CancelationNotificationResponse, CancelationNotificationSearchObject, object, object>
    {
        private readonly ICancelationNotificationService _service;

        public CancelationNotificationController(ICancelationNotificationService service) : base(service)
        {
            _service = service;
        }

        [HttpPut("{id}/mark-as-seen")]
        public async Task<IActionResult> MarkAsSeen(int id)
        {
            await _service.MarkAsSeenAsync(id);
            return Ok();
        }

        [HttpGet("unseen-count")]
        public async Task<ActionResult<int>> GetUnseenCount()
        {
            return await _service.GetUnseenCountAsync();
        }
    }
}
