using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Model;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.WebAPI.Controllers
{
    [Route("api/payments")]
    [ApiController]
    public class PaymentController : ControllerBase
    {
        private readonly IStripePaymentService _stripePaymentService;
        private readonly TerminBaContext _context;

        public PaymentController(
            IStripePaymentService stripePaymentService,
            TerminBaContext context)
        {
            _stripePaymentService = stripePaymentService;
            _context = context;
        }

        [Authorize]
        [HttpPost("create-payment-intent")]
        public async Task<ActionResult<PaymentIntentResponse>> CreatePaymentIntent(
            [FromBody] PaymentIntentRequest request)
        {
            if (request.Amount <= 0)
            {
                return BadRequest(new { message = "Amount must be greater than zero." });
            }

            try
            {
                var result = await _stripePaymentService.CreatePaymentIntentAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }

        [Authorize]
        [HttpPost("confirm/{paymentIntentId}")]
        public async Task<IActionResult> ConfirmPaymentIntent(string paymentIntentId)
        {
            try
            {
                var status = await _stripePaymentService.ConfirmPaymentAsync(paymentIntentId);
                return Ok(new { status = status });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }
    }
}
