using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Stripe;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class StripePaymentService : IStripePaymentService
    {

        private readonly Database.TerminBaContext _context;

        public StripePaymentService(Database.TerminBaContext context)
        {
            _context = context;
            var secretKey = Environment.GetEnvironmentVariable("StripeSecretKey")
                ?? throw new InvalidOperationException("StripeSecretKey environment variable is not set.");

            StripeConfiguration.ApiKey = secretKey;
        }

        public async Task<PaymentIntentResponse> CreatePaymentIntentAsync(PaymentIntentRequest request)
        {
            var reservation = await _context.Reservations
                .Include(r => r.Facility)
                    .ThenInclude(f => f.DynamicPrices)
                .FirstOrDefaultAsync(r => r.Id == request.ReservationId);

            if (reservation == null)
            {
                throw new UserException($"Reservation with ID {request.ReservationId} not found.");
            }

            var isAlreadyPaid = await _context.Payments
                .AnyAsync(p => p.ReservationId == request.ReservationId && p.Status == Enums.PaymentStatus.Paid);

            if (isAlreadyPaid)
            {
                throw new UserException("This reservation has already been paid for.");
            }

            if (reservation.Facility == null)
            {
                throw new UserException($"Facility for Reservation {request.ReservationId} not found.");
            }

            var expectedPrice = TerminBA.Services.Helpers.DynamicPriceHelper.GetExpectedPrice(
                reservation.Facility,
                reservation.ReservationDate,
                reservation.StartTime,
                reservation.EndTime);

            var expectedAmount = (long)expectedPrice;

            if (expectedAmount != request.Amount)
            {
                throw new UserException("Amount mismatch between request and calculated price.");
            }

            var options = new PaymentIntentCreateOptions
            {
                Amount = request.Amount,
                Currency = request.Currency.ToLowerInvariant(),
                PaymentMethodTypes = new List<string> { "card" },
                Metadata = new Dictionary<string, string>
                {
                    { "facilityId", request.FacilityId?.ToString() ?? string.Empty },
                    { "userId",     request.UserId?.ToString()     ?? string.Empty },
                    { "reservationId", request.ReservationId.ToString() },
                    { "source",     "TerminBA-Mobile" },
                },
            };

            var service = new PaymentIntentService();

            try
            {
                var paymentIntent = await service.CreateAsync(options);

                return new PaymentIntentResponse
                {
                    ClientSecret    = paymentIntent.ClientSecret,
                    PaymentIntentId = paymentIntent.Id,
                    Status          = paymentIntent.Status,
                };
            }
            catch (StripeException ex)
            {
                throw new Exception($"Payment processing failed: {ex.StripeError?.Message ?? "unknown error"}");
            }
        }

        public async Task<PaymentIntent> GetPaymentIntentAsync(string paymentIntentId)
        {
            var service = new PaymentIntentService();
            try
            {
                return await service.GetAsync(paymentIntentId);
            }
            catch (StripeException ex)
            {
                throw new Exception($"Failed to get payment intent: {ex.StripeError?.Message ?? "unknown error"}");
            }
        }

        public async Task<string> ConfirmPaymentAsync(string paymentIntentId)
        {
            var paymentIntent = await GetPaymentIntentAsync(paymentIntentId);

            if (paymentIntent.Status == "succeeded")
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

            return paymentIntent.Status;
        }

        public async Task<string> CreateRefundAsync(string paymentIntentId, decimal amount)
        {
            var options = new RefundCreateOptions
            {
                PaymentIntent = paymentIntentId,
                Amount = (long)(amount * 100)
            };
            
            var service = new RefundService();
            try
            {
                var refund = await service.CreateAsync(options);
                return refund.Id;
            }
            catch (StripeException ex)
            {
                throw new Exception($"Refund failed: {ex.StripeError?.Message ?? "unknown error"}");
            }
        }
    }
}
