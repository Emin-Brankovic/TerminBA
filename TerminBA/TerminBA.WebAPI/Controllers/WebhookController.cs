using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Stripe;
using System.IO;
using System.Threading.Tasks;
using System;
using Microsoft.Extensions.Logging;
using TerminBA.Services.Database;

namespace TerminBA.WebAPI.Controllers
{
    [Route("api/webhook")]
    [ApiController]
    public class WebhookController : ControllerBase
    {
        private readonly TerminBaContext _context;

        public WebhookController(TerminBaContext context)
        {
            _context = context;
        }

        [HttpPost]
        public async Task<IActionResult> Index()
        {
            var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
            try
            {
                // Note: For a production environment, verify the webhook signature here.
                var stripeEvent = EventUtility.ParseEvent(json);

                if (stripeEvent.Type == EventTypes.PaymentIntentSucceeded)
                {
                    var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                    if (paymentIntent != null)
                    {
                        var payment = await _context.Payments.FirstOrDefaultAsync(p => p.StripePaymentIntentId == paymentIntent.Id);
                        if (payment == null)
                        {
                            payment = new TerminBA.Services.Database.Payment
                            {
                                ReservationId = int.Parse(paymentIntent.Metadata["reservationId"]),
                                UserId = int.Parse(paymentIntent.Metadata["userId"]),
                                Provider = "stripe",
                                StripePaymentIntentId = paymentIntent.Id,
                                Amount = paymentIntent.Amount / 100m,
                                Currency = paymentIntent.Currency,
                                Status = TerminBA.Services.Enums.PaymentStatus.Paid,
                                CreatedAt = DateTime.Now,
                                UpdatedAt = DateTime.Now,
                                PaidAt = DateTime.Now
                            };
                            _context.Payments.Add(payment);
                        }
                        else
                        {
                            payment.Status = TerminBA.Services.Enums.PaymentStatus.Paid;
                            payment.PaidAt = DateTime.Now;
                            payment.UpdatedAt = DateTime.Now;
                        }

                        var reservation = await _context.Reservations.FindAsync(payment.ReservationId);
                        if (reservation != null && reservation.Status == "PendingReservationState")
                        {
                            reservation.Status = "ActiveReservationState";
                        }

                        await _context.SaveChangesAsync();
                    }
                }
                else if (stripeEvent.Type == EventTypes.ChargeRefundUpdated)
                {
                    var refund = stripeEvent.Data.Object as Refund;
                    if (refund != null)
                    {
                        var payment = await _context.Payments.FirstOrDefaultAsync(p => p.StripeRefundId == refund.Id);
                        if (payment != null)
                        {
                            if (refund.Status == "succeeded")
                            {
                                payment.Status = TerminBA.Services.Enums.PaymentStatus.Refunded;
                                payment.RefundedAt = DateTime.Now;
                            }
                            else if (refund.Status == "failed")
                            {
                                payment.Status = TerminBA.Services.Enums.PaymentStatus.RefundFailed;
                            }
                            await _context.SaveChangesAsync();
                        }
                    }
                }

                return Ok();
            }
            catch (StripeException e)
            {
                return BadRequest();
            }
            catch (Exception ex)
            {
                return StatusCode(500);
            }
        }
    }
}
