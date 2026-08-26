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
    public class ReservationController : BaseCRUDController<ReservationResponse, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>
    {
        private readonly IReservationService _reservationService;

        public ReservationController(IReservationService reservationService) : base(reservationService)
        {
            _reservationService = reservationService;
        }

        [Authorize(Roles = "User,Sport center")]
        [HttpPut("cancel/{id}")]
        public async Task<CancellationResponse> Cancel(int id)
        {
            return await _reservationService.CancelAsync(id);
        }

        [Authorize(Roles = "User")]
        [HttpPost]
        public override Task<ReservationResponse> Create([FromBody] ReservationInsertRequest request)
        {
            return base.Create(request);
        }

        [Authorize(Roles = "User,Sport center")]
        [HttpPut("{id}")]
        override public async Task<ReservationResponse?> Update(int id, [FromBody] ReservationUpdateRequest request)
        {
            return await _crudService.UpdateAsync(id, request);
        }
    }
}