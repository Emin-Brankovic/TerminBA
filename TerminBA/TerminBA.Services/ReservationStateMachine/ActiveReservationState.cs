using EasyNetQ;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stripe;
using Microsoft.Extensions.DependencyInjection;
using TerminBA.Models.Execptions;
using TerminBA.Models.Messages;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.PlayRequestStateMachine;
using TerminBA.Services.PostStateMachine;

namespace TerminBA.Services.ReservationStateMachine
{
    public class ActiveReservationState : BaseReservationState
    {
        public ActiveReservationState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper)
            : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<ReservationResponse> CreateAsync(ReservationInsertRequest request)
        {
            var entity = new Reservation();
            entity = _mapper.Map(request, entity);
            entity.Status = nameof(ActiveReservationState);

            var facility = await _context.Facilities.Include(f => f.SportCenter).FirstOrDefaultAsync(f => f.Id == request.FacilityId);
            var hours = facility?.SportCenter?.CancellationDeadlineHours ?? 24;
            var reservationStart = request.ReservationDate.ToDateTime(request.StartTime);
            var reservationStartUtc = TimeHelper.ConvertToUtc(reservationStart);
            entity.CancellationDeadline = reservationStartUtc.AddHours(-hours);

            await ValidateReservationInsertAsync(request);

            await _context.Reservations.AddAsync(entity);
            await _context.SaveChangesAsync();
            
            return _mapper.Map<ReservationResponse>(entity);
        }

        public override async Task<ReservationResponse> UpdateAsync(int id, ReservationUpdateRequest request)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var entity = await _context.Reservations
                    .FirstOrDefaultAsync(r => r.Id == id);

                if (entity == null)
                    throw new UserException("Reservation was not found");

                await ValidateReservationUpdateAsync(entity, request);

                var targetFacilityId = request.FacilityId ?? entity.FacilityId;
                var facility = await _context.Facilities.FirstOrDefaultAsync(f => f.Id == targetFacilityId);
                bool usesDynamicPricing = facility != null && facility.IsDynamicPricing;

                bool isStripePayment = string.Equals(entity.PaymentMethod, "Stripe", StringComparison.OrdinalIgnoreCase);

                if (isStripePayment && usesDynamicPricing)
                {
                    var payments = await _context.Payments
                        .Where(p => p.ReservationId == id && p.Status == TerminBA.Services.Enums.PaymentStatus.Paid)
                        .ToListAsync();

                    if (payments.Any())
                    {
                        var latestPayment = payments.OrderByDescending(p => p.CreatedAt).First();
                        decimal totalPaid = payments.Sum(p => p.Amount - (p.RefundAmount ?? 0));
                        decimal newPrice = request.Price;

                        if (newPrice > totalPaid)
                        {
                            decimal diff = newPrice - totalPaid;
                            try
                            {
                                // Force initialization of Stripe API key
                                _serviceProvider.GetRequiredService<TerminBA.Services.Interfaces.IStripePaymentService>();

                                var paymentIntentService = new PaymentIntentService();
                                var originalIntent = await paymentIntentService.GetAsync(latestPayment.StripePaymentIntentId);

                                var options = new PaymentIntentCreateOptions
                                {
                                    Amount = (long)(diff * 100),
                                    Currency = originalIntent.Currency,
                                    PaymentMethod = originalIntent.PaymentMethodId,
                                    Customer = originalIntent.CustomerId,
                                    Confirm = true,
                                    OffSession = true
                                };
                                var newIntent = await paymentIntentService.CreateAsync(options);

                                var additionalPayment = new Payment
                                {
                                    ReservationId = id,
                                    UserId = latestPayment.UserId,
                                    Provider = "stripe",
                                    StripePaymentIntentId = newIntent.Id,
                                    Amount = diff,
                                    Currency = newIntent.Currency,
                                    Status = TerminBA.Services.Enums.PaymentStatus.Paid,
                                    CreatedAt = DateTime.UtcNow,
                                    UpdatedAt = DateTime.UtcNow,
                                    PaidAt = DateTime.UtcNow
                                };
                                _context.Payments.Add(additionalPayment);
                            }
                            catch (StripeException ex)
                            {
                                if (ex.StripeError?.Code == "payment_method_unattached" || ex.StripeError?.Message?.Contains("Customer attachment") == true)
                                {
                                    throw new UserException("Cannot automatically charge your card for the price difference because the original payment was not saved for future use. Please cancel and recreate the reservation.");
                                }
                                throw new UserException($"Payment adjustment failed: {ex.StripeError?.Message ?? ex.Message}");
                            }
                            catch (Exception ex)
                            {
                                throw new UserException($"Payment adjustment failed: {ex.Message}");
                            }
                        }
                        else if (newPrice < totalPaid)
                        {
                            decimal diff = totalPaid - newPrice;
                            try
                            {
                                var stripeService = _serviceProvider.GetRequiredService<TerminBA.Services.Interfaces.IStripePaymentService>();
                                
                                var refundablePayments = payments
                                    .Where(p => (p.Amount - (p.RefundAmount ?? 0)) > 0)
                                    .OrderByDescending(p => p.CreatedAt)
                                    .ToList();

                                decimal remainingRefund = diff;

                                foreach (var p in refundablePayments)
                                {
                                    if (remainingRefund <= 0) break;

                                    decimal availableToRefundFromPayment = p.Amount - (p.RefundAmount ?? 0);
                                    decimal amountToRefundFromPayment = Math.Min(remainingRefund, availableToRefundFromPayment);

                                    var refundId = await stripeService.CreateRefundAsync(p.StripePaymentIntentId, amountToRefundFromPayment);

                                    p.StripeRefundId = refundId;
                                    p.RefundAmount = (p.RefundAmount ?? 0) + amountToRefundFromPayment;
                                    p.RefundRequestedAt = DateTime.UtcNow;
                                    p.RefundedAt = DateTime.UtcNow;
                                    _context.Payments.Update(p);

                                    remainingRefund -= amountToRefundFromPayment;
                                }
                            }
                            catch (Exception ex)
                            {
                                throw new UserException($"Payment adjustment failed: {ex.Message}");
                            }
                        }
                    }
                }

                _mapper.Map(request, entity);
                
                var fac = await _context.Facilities.Include(f => f.SportCenter).FirstOrDefaultAsync(f => f.Id == entity.FacilityId);
                var hours = fac?.SportCenter?.CancellationDeadlineHours ?? 24;
                var reservationStart = entity.ReservationDate.ToDateTime(entity.StartTime);
                var reservationStartUtc = TimeHelper.ConvertToUtc(reservationStart);
                entity.CancellationDeadline = reservationStartUtc.AddHours(-hours);

                entity.Status = nameof(ActiveReservationState);

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return _mapper.Map<ReservationResponse>(entity);
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        public override async Task<CancellationResponse> CancelAsync(int id)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var entity = await _context.Reservations
                    .Include(r => r.Facility)
                    .FirstOrDefaultAsync(r => r.Id == id);

                if (entity == null)
                    throw new UserException("Reservation was not found");

                decimal? actualRefundAmount = null;

                if (string.Equals(entity.PaymentMethod, "Stripe", StringComparison.OrdinalIgnoreCase))
                {
                    var payments = await _context.Payments
                        .Where(p => p.ReservationId == id && p.Status == TerminBA.Services.Enums.PaymentStatus.Paid)
                        .ToListAsync();

                    var refundablePayments = payments
                        .Where(p => (p.Amount - (p.RefundAmount ?? 0)) > 0)
                        .OrderByDescending(p => p.CreatedAt)
                        .ToList();

                    if (refundablePayments.Any())
                    {
                        decimal totalPaid = refundablePayments.Sum(p => p.Amount - (p.RefundAmount ?? 0));
                        bool missedDeadline = entity.CancellationDeadline.HasValue && entity.CancellationDeadline < DateTime.UtcNow;
                        decimal totalRefundAmount = missedDeadline ? Math.Round(totalPaid * 0.3m, 2) : totalPaid;

                        var stripeService = _serviceProvider.GetRequiredService<TerminBA.Services.Interfaces.IStripePaymentService>();
                        decimal remainingRefund = totalRefundAmount;

                        foreach (var p in refundablePayments)
                        {
                            if (remainingRefund <= 0) break;

                            decimal availableToRefundFromPayment = p.Amount - (p.RefundAmount ?? 0);
                            decimal amountToRefundFromPayment = Math.Min(remainingRefund, availableToRefundFromPayment);

                            var refundId = await stripeService.CreateRefundAsync(p.StripePaymentIntentId, amountToRefundFromPayment);

                            p.StripeRefundId = refundId;
                            p.RefundAmount = (p.RefundAmount ?? 0) + amountToRefundFromPayment;
                            p.RefundRequestedAt = DateTime.UtcNow;
                            p.Status = TerminBA.Services.Enums.PaymentStatus.RefundPending;
                            _context.Payments.Update(p);

                            remainingRefund -= amountToRefundFromPayment;
                        }

                        entity.Status = nameof(CanceledWithRefundReservationState);
                        actualRefundAmount = totalRefundAmount;
                    }
                    else
                    {
                        entity.Status = nameof(CanceledWithoutRefundReservationState);
                    }
                }
                else
                {
                    entity.Status = nameof(CanceledWithoutRefundReservationState);
                }

                entity.CanceledAt = DateTime.UtcNow;

                var post = await _context.Posts.FirstOrDefaultAsync(p => p.ReservationId == id);
                if (post != null)
                {
                    post.PostState = nameof(CanceledReservationPostState);

                    var pendingRequests = await _context.PlayRequests
                        .Where(pr => pr.PostId == post.Id && pr.PlayRequestState == nameof(PendingPlayRequestState))
                        .ToListAsync();

                    foreach (var pr in pendingRequests)
                    {
                        pr.PlayRequestState = nameof(ExpiredPlayRequestState);
                        pr.Reason = "The reservation was canceled before the post owner evaluated your request.";
                    }

                    var acceptedRequests = await _context.PlayRequests
                        .Where(pr => pr.PostId == post.Id && pr.PlayRequestState == nameof(AcceptedPlayRequestState))
                        .ToListAsync();

                    var notificationHubService = _serviceProvider.GetService<TerminBA.Services.Interfaces.INotificationsHubService>();
                    if (notificationHubService != null && acceptedRequests.Any())
                    {
                        var postOwner = await _context.Users.FindAsync(entity.UserId);
                        var facilityName = entity.Facility?.Name ?? "Unknown facility";

                        foreach (var ar in acceptedRequests)
                        {
                            var notification = new CancelationNotification
                            {
                                PostOwnerId = ar.RequesterId, // The player receiving the notification
                                ReservationId = id,
                                RequesterName = postOwner != null ? $"{postOwner.FirstName} {postOwner.LastName}" : "The post owner",
                                FacilityName = facilityName,
                                DateCancelled = DateTime.UtcNow,
                                IsSeen = false
                            };
                            _context.CancelationNotifications.Add(notification);

                            var payload = new
                            {
                                type = "reservation_canceled",
                                postId = post.Id,
                                reservationId = id,
                                canceledAt = DateTime.UtcNow.ToString("o")
                            };
                            await notificationHubService.SendReservationCanceledNotificationAsync(ar.RequesterId, payload);
                        }
                    }
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return new CancellationResponse
                {
                    ReservationState = entity.Status,
                    RefundIssued = entity.Status == nameof(CanceledWithRefundReservationState),
                    RefundAmount = actualRefundAmount,
                    RefundStatus = entity.Status == nameof(CanceledWithRefundReservationState) ? "RefundPending" : null
                };
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        private async Task ValidateReservationInsertAsync(ReservationInsertRequest request)
        {
            ValidateReservationNotInPast(request.ReservationDate, request.StartTime);

            var timeSlots = await TimeSlotHelper.GenerateTimeSlots(request.FacilityId, request.ReservationDate, _context);

            var exists = timeSlots.Any(t =>
                t.Start == request.StartTime.ToTimeSpan() &&
                t.End == request.EndTime.ToTimeSpan());

            if (!exists)
                throw new UserException("Can't pick a non existing time slot");

            var hasConflict = await _context.Reservations
                .AnyAsync(r => r.FacilityId == request.FacilityId
                               && r.ReservationDate == request.ReservationDate
                               && request.StartTime < r.EndTime
                               && request.EndTime > r.StartTime
                               && r.Status == nameof(ActiveReservationState));

            if (hasConflict)
                throw new UserException("Can't pick a booked time slot.");

            var facility = await _context.Facilities
                .Include(f => f.DynamicPrices)
                .FirstOrDefaultAsync(f => f.Id == request.FacilityId);

            if (facility == null)
                throw new UserException("Facility not found.");

            var expectedPrice = DynamicPriceHelper.GetExpectedPrice(
                facility,
                request.ReservationDate,
                request.StartTime,
                request.EndTime);

            if (request.Price != expectedPrice)
                throw new UserException($"Invalid price for selected time slot and reservation date.");
        }


        private async Task ValidateReservationUpdateAsync(Reservation entity, ReservationUpdateRequest request)
        {
            ValidateReservationNotInPast(request.ReservationDate, request.StartTime);

            var targetFacilityId = request.FacilityId ?? entity.FacilityId;

            var allSlots = await TimeSlotHelper.GenerateTimeSlots(targetFacilityId, request.ReservationDate, _context);
            var slot = allSlots.FirstOrDefault(t =>
                t.Start == request.StartTime.ToTimeSpan() &&
                t.End == request.EndTime.ToTimeSpan());

            if (slot == default)
                throw new UserException("Can't pick a non existing time slot.");

            var hasConflict = await _context.Reservations
                .AnyAsync(r => r.FacilityId == targetFacilityId
                               && r.ReservationDate == request.ReservationDate
                               && r.Id != entity.Id
                               && request.StartTime < r.EndTime
                               && request.EndTime > r.StartTime
                               && r.Status == nameof(ActiveReservationState));

            if (hasConflict)
                throw new UserException("Can't pick a booked time slot.");

            var facility = await _context.Facilities
                .Include(f => f.DynamicPrices)
                .FirstOrDefaultAsync(f => f.Id == targetFacilityId);

            if (facility == null)
                throw new UserException("Facility not found.");

            var expectedPrice = DynamicPriceHelper.GetExpectedPrice(
                facility,
                request.ReservationDate,
                request.StartTime,
                request.EndTime);

            if (request.Price != expectedPrice)
                throw new UserException($"Invalid price for selected time slot and reservation date.");
        }

        private static void ValidateReservationNotInPast(DateOnly reservationDate, TimeOnly reservationStartTime)
        {
            var now = TimeHelper.GetFacilityNow();
            var today = DateOnly.FromDateTime(now);

            if (reservationDate < today)
            {
                throw new UserException("Can't make a reservation in the past.");
            }

            if (reservationDate == today && reservationStartTime.ToTimeSpan() <= now.TimeOfDay)
            {
                throw new UserException("Can't make a reservation in the past.");
            }
        }

        private async Task SendEmailAsync(ReservationInsertRequest reservation)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == reservation.UserId);

            if (user == null)
                throw new UserException("User not found");

            var bus = _serviceProvider.GetService<IBus>()
                ?? throw new UserException("Message bus is not configured");

            var emailMessage = new EmailMessage
            {
                RecipientEmail = user.Email ?? string.Empty,
                MessageBody = "Your reservation has been successfully created. Thank you"
            };

            await bus.PubSub.PublishAsync(emailMessage);
        }
    }
}
