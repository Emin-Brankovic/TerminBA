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
    public class ReservationController : BaseCRUDController<ReservationResponse, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>
    {
        private readonly IReservationService _reservationService;

        public ReservationController(IReservationService reservationService) : base(reservationService)
        {
            _reservationService = reservationService;
        }

        [HttpPut("cancel/{id}")]
        public async Task<ReservationResponse> Cancel(int id)
        {
            return await _reservationService.CancelAsync(id);
        }
    }
}