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
        private readonly PaymentIntentService? _paymentIntentService;
        private readonly CustomerService? _customerService;

        public StripePaymentService(
            Database.TerminBaContext context,
            IBus bus,
            IAuthService<AccountBase> authService,
            BaseReservationState baseReservationState)
            : this(context, bus, authService, baseReservationState, null, null)
        {
        }

        public StripePaymentService(
            Database.TerminBaContext context,
            IBus bus,
            IAuthService<AccountBase> authService,
            BaseReservationState baseReservationState,
            PaymentIntentService? paymentIntentService,
            CustomerService? customerService)
        {
            _context = context;
            _bus = bus;
            _authService = authService;
            _baseReservationState = baseReservationState;
            _paymentIntentService = paymentIntentService;
            _customerService = customerService;

            var secretKey = Environment.GetEnvironmentVariable("StripeSecretKey");
            if (!string.IsNullOrEmpty(secretKey))
            {
                StripeConfiguration.ApiKey = secretKey;
            }
            else if (_paymentIntentService == null)
            {
                throw new InvalidOperationException("StripeSecretKey environment variable is not set.");
            }
        }

        private PaymentIntentService GetPaymentIntentService() => _paymentIntentService ?? new PaymentIntentService();
        private CustomerService GetCustomerService() => _customerService ?? new CustomerService();

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

                var existingPayments = await _context.Payments
                    .Where(p => p.ReservationId == request.ReservationId)
                    .ToListAsync();

                if (existingPayments.Any(p => p.Status == TerminBA.Services.Enums.PaymentStatus.Paid))
                {
                    throw new UserException("This reservation already has an active or completed payment attempt.");
                }

                var paymentIntentService = GetPaymentIntentService();
                var pendingAttempts = existingPayments
                    .Where(p => p.Status == TerminBA.Services.Enums.PaymentStatus.RequiresPayment)
                    .ToList();

                bool hasGenuinelyActivePayment = false;

                foreach (var pendingPayment in pendingAttempts)
                {
                    if (string.IsNullOrEmpty(pendingPayment.StripePaymentIntentId))
                    {
                        pendingPayment.Status = TerminBA.Services.Enums.PaymentStatus.Canceled;
                        pendingPayment.UpdatedAt = DateTime.UtcNow;
                        continue;
                    }

                    try
                    {
                        var stripeIntent = await paymentIntentService.GetAsync(pendingPayment.StripePaymentIntentId);

                        if (stripeIntent.Status == "succeeded")
                        {
                            pendingPayment.Status = TerminBA.Services.Enums.PaymentStatus.Paid;
                            pendingPayment.PaidAt = DateTime.UtcNow;
                            pendingPayment.UpdatedAt = DateTime.UtcNow;

                            if (reservation.Status == nameof(PendingReservationState))
                            {
                                var state = _baseReservationState.GetReservationState(reservation.Status);
                                await state.ConfirmPaymentAsync(reservation.Id, TerminBA.Models.Enums.PaymentMethod.Stripe.ToString());
                            }

                            await _context.SaveChangesAsync();
                            await transaction.CommitAsync();
                            throw new UserException("This reservation already has an active or completed payment attempt.");
                        }
                        else if (stripeIntent.Status == "processing")
                        {
                            hasGenuinelyActivePayment = true;
                            break;
                        }
                        else if (stripeIntent.Status == "requires_action" && pendingPayment.CreatedAt > DateTime.UtcNow.AddMinutes(-15))
                        {
                            hasGenuinelyActivePayment = true;
                            break;
                        }
                        else
                        {
                            // Abandoned or cancelled card entry attempt
                            if (stripeIntent.Status != "canceled")
                            {
                                try
                                {
                                    await paymentIntentService.CancelAsync(pendingPayment.StripePaymentIntentId, new PaymentIntentCancelOptions
                                    {
                                        CancellationReason = "abandoned"
                                    });
                                }
                                catch (StripeException)
                                {
                                    // Ignore if cannot cancel in Stripe
                                }
                            }

                            pendingPayment.Status = TerminBA.Services.Enums.PaymentStatus.Canceled;
                            pendingPayment.UpdatedAt = DateTime.UtcNow;
                        }
                    }
                    catch (StripeException)
                    {
                        pendingPayment.Status = TerminBA.Services.Enums.PaymentStatus.Canceled;
                        pendingPayment.UpdatedAt = DateTime.UtcNow;
                    }
                }

                if (hasGenuinelyActivePayment)
                {
                    throw new UserException("This reservation already has an active or completed payment attempt.");
                }

                await _context.SaveChangesAsync();

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
                    var customerService = GetCustomerService();
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

                var paymentIntent = await paymentIntentService.CreateAsync(options);

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
                throw new UserException($"Payment processing failed: {ex.StripeError?.Message ?? "unknown error"}");
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        public async Task<PaymentIntent> GetPaymentIntentAsync(string paymentIntentId)
        {
            var service = GetPaymentIntentService();
            try
            {
                return await service.GetAsync(paymentIntentId);
            }
            catch (StripeException ex)
            {
                throw new UserException($"Failed to get payment intent: {ex.StripeError?.Message ?? "unknown error"}");
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

                await _context.SaveChangesAsync();
            }
            else if (paymentIntent.Status == "canceled")
            {
                var payment = await _context.Payments.FirstOrDefaultAsync(p => p.StripePaymentIntentId == paymentIntent.Id);
                if (payment != null && payment.Status != TerminBA.Services.Enums.PaymentStatus.Paid)
                {
                    payment.Status = TerminBA.Services.Enums.PaymentStatus.Canceled;
                    payment.UpdatedAt = DateTime.UtcNow;
                    await _context.SaveChangesAsync();
                }
            }

            return paymentIntent.Status;
        }

        public async Task<string> CancelPaymentIntentAsync(string paymentIntentId)
        {
            var currentUserIdStr = _authService.GetUserId();
            if (string.IsNullOrEmpty(currentUserIdStr) || !int.TryParse(currentUserIdStr, out int currentUserId))
            {
                throw new UserException("User is not authenticated.");
            }

            var payment = await _context.Payments.FirstOrDefaultAsync(p => p.StripePaymentIntentId == paymentIntentId);
            if (payment == null)
            {
                throw new UserException($"Payment with PaymentIntentId '{paymentIntentId}' not found.");
            }

            if (payment.UserId != currentUserId)
            {
                throw new UserException("You are not authorized to cancel this payment.");
            }

            if (payment.Status == TerminBA.Services.Enums.PaymentStatus.Paid)
            {
                throw new UserException("Cannot cancel a completed payment.");
            }

            if (payment.Status == TerminBA.Services.Enums.PaymentStatus.Canceled)
            {
                return "canceled";
            }

            var paymentIntentService = GetPaymentIntentService();
            try
            {
                var stripeIntent = await paymentIntentService.GetAsync(paymentIntentId);
                if (stripeIntent != null && stripeIntent.Status != "canceled" && stripeIntent.Status != "succeeded")
                {
                    await paymentIntentService.CancelAsync(paymentIntentId, new PaymentIntentCancelOptions
                    {
                        CancellationReason = "abandoned"
                    });
                }
            }
            catch (StripeException)
            {
                // Handled gracefully if Stripe fails or is already canceled
            }

            payment.Status = TerminBA.Services.Enums.PaymentStatus.Canceled;
            payment.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return "canceled";
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
                throw new UserException($"Refund failed: {ex.StripeError?.Message ?? "unknown error"}");
            }
        }
    }
}
