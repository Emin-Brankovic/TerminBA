using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TerminBA.Models.Model;
using TerminBA.Services.Interfaces;

namespace TerminBA.WebAPI.Controllers
{
    [Route("api/payments")]
    [ApiController]
    public class PaymentController : ControllerBase
    {
        private readonly IStripePaymentService _stripePaymentService;

        public PaymentController(
            IStripePaymentService stripePaymentService)
        {
            _stripePaymentService = stripePaymentService;
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
    }
}
