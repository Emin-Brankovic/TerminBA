using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Stripe;
using TerminBA.Models.Exceptions;
using TerminBA.Models.Model;
using TerminBA.Services.Interfaces;
using EasyNetQ;
using TerminBA.Models.Messages;
using TerminBA.Services.Helpers;
using TerminBA.Services.ReservationStateMachine;
using TerminBA.Services.Database;
using TerminBA.Models.Enums;

namespace TerminBA.Services.Service
{
    public class StripePaymentService : IStripePaymentService
    {
        private readonly Database.TerminBaContext _context;
        private readonly IBus _bus;
        private readonly IAuthService<AccountBase> _authService;
        private readonly BaseReservationState _baseReservationState;

        public StripePaymentService(Database.TerminBaContext context, IBus bus, IAuthService<AccountBase> authService, BaseReservationState baseReservationState)
        {
            _context = context;
            _bus = bus;
            _authService = authService;
            _baseReservationState = baseReservationState;
            var secretKey = Environment.GetEnvironmentVariable("StripeSecretKey")
                ?? throw new InvalidOperationException("StripeSecretKey environment variable is not set.");

            StripeConfiguration.ApiKey = secretKey;
        }

        public async Task<PaymentIntentResponse> CreatePaymentIntentAsync(PaymentIntentRequest request)
        {
            var currentUserIdStr = _authService.GetUserId();
            if (string.IsNullOrEmpty(currentUserIdStr) || !int.TryParse(currentUserIdStr, out int currentUserId))
            {
                throw new UserException("User is not authenticated.");
            }

            await using var transaction = await _context.Database.BeginTransactionAsync(System.Data.IsolationLevel.Serializable);
            try
            {
                var reservation = await _context.Reservations
                    .Include(r => r.Facility)
                        .ThenInclude(f => f.DynamicPrices)
                    .FirstOrDefaultAsync(r => r.Id == request.ReservationId);

                if (reservation == null)
                {
                    throw new UserException($"Reservation with ID {request.ReservationId} not found.");
                }

                if (reservation.UserId != currentUserId)
                {
                    throw new UserException("You are not authorized to pay for this reservation.");
                }

                if (reservation.Status != nameof(PendingReservationState))
                {
                    throw new UserException("Payment can only be initiated for reservations in Pending state.");
                }

                if (!string.IsNullOrEmpty(reservation.PaymentMethod) && 
                    !reservation.PaymentMethod.Equals(TerminBA.Models.Enums.PaymentMethod.Stripe.ToString(), StringComparison.OrdinalIgnoreCase))
                {
                    throw new UserException("This reservation is not configured to use Stripe payments.");
                }

                if (reservation.Facility == null)
                {
                    throw new UserException($"Facility for Reservation {request.ReservationId} not found.");
                }

                var hasActiveOrCompletedPayment = await _context.Payments
                    .AnyAsync(p => p.ReservationId == request.ReservationId && 
                                  (p.Status == TerminBA.Services.Enums.PaymentStatus.Paid || 
                                   p.Status == TerminBA.Services.Enums.PaymentStatus.RequiresPayment));

                if (hasActiveOrCompletedPayment)
                {
                    throw new UserException("This reservation already has an active or completed payment attempt.");
                }

                var expectedPrice = TerminBA.Services.Helpers.DynamicPriceHelper.GetExpectedPrice(
                    reservation.Facility,
                    reservation.ReservationDate,
                    reservation.StartTime,
                    reservation.EndTime);

                var expectedAmount = (long)(expectedPrice * 100);

                Stripe.Customer customer = null;
                var user = await _context.Users.FindAsync(currentUserId);
                if (user != null && !string.IsNullOrEmpty(user.Email))
                {
                    var customerService = new CustomerService();
                    var existingCustomers = await customerService.ListAsync(new CustomerListOptions { Email = user.Email, Limit = 1 });
                    if (existingCustomers.Any())
                    {
                        customer = existingCustomers.First();
                    }
                    else
                    {
                        customer = await customerService.CreateAsync(new CustomerCreateOptions
                        {
                            Email = user.Email,
                            Name = $"{user.FirstName} {user.LastName}",
                            Metadata = new Dictionary<string, string> { { "userId", user.Id.ToString() } }
                        });
                    }
                }

                var options = new PaymentIntentCreateOptions
                {
                    Amount = expectedAmount,
                    Currency = "bam",
                    PaymentMethodTypes = new List<string> { "card" },
                    Metadata = new Dictionary<string, string>
                    {
                        { "facilityId", reservation.FacilityId?.ToString() ?? string.Empty },
                        { "userId",     currentUserId.ToString() },
                        { "reservationId", request.ReservationId.ToString() },
                        { "source",     "TerminBA-Mobile" },
                    },
                };

                if (customer != null)
                {
                    options.Customer = customer.Id;
                    options.SetupFutureUsage = "off_session";
                }

                var service = new PaymentIntentService();
                var paymentIntent = await service.CreateAsync(options);

                var payment = new TerminBA.Services.Database.Payment
                {
                    ReservationId = reservation.Id,
                    UserId = currentUserId,
                    Provider = "stripe",
                    StripePaymentIntentId = paymentIntent.Id,
                    Amount = expectedAmount / 100m,
                    Currency = "bam",
                    Status = TerminBA.Services.Enums.PaymentStatus.RequiresPayment,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                
                _context.Payments.Add(payment);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return new PaymentIntentResponse
                {
                    ClientSecret    = paymentIntent.ClientSecret,
                    PaymentIntentId = paymentIntent.Id,
                    Status          = paymentIntent.Status,
                };
            }
            catch (StripeException ex)
            {
                await transaction.RollbackAsync();
                throw new Exception($"Payment processing failed: {ex.StripeError?.Message ?? "unknown error"}");
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
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
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow,
                        PaidAt = DateTime.UtcNow
                    };
                    _context.Payments.Add(payment);
                }
                else
                {
                    payment.Status = TerminBA.Services.Enums.PaymentStatus.Paid;
                    payment.PaidAt = DateTime.UtcNow;
                    payment.UpdatedAt = DateTime.UtcNow;
                }

                var reservation = await _context.Reservations.FindAsync(payment.ReservationId);
                if (reservation != null && reservation.Status == nameof(PendingReservationState))
                {
                    var state = _baseReservationState.GetReservationState(reservation.Status);
                    await state.ConfirmPaymentAsync(reservation.Id, TerminBA.Models.Enums.PaymentMethod.Stripe.ToString());
                }
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
