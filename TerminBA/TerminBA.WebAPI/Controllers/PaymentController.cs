using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Model;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.WebAPI.Controllers
{
    [Authorize(Roles = "User")]
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

        [HttpPost("create-payment-intent")]
        public async Task<ActionResult<PaymentIntentResponse>> CreatePaymentIntent(
            [FromBody] PaymentIntentRequest request)
        {
            var result = await _stripePaymentService.CreatePaymentIntentAsync(request);
            return Ok(result);
        }

        [HttpPost("confirm/{paymentIntentId}")]
        public async Task<IActionResult> ConfirmPaymentIntent(string paymentIntentId)
        {
            var status = await _stripePaymentService.ConfirmPaymentAsync(paymentIntentId);
            return Ok(new { status = status });
        }
    }
}
