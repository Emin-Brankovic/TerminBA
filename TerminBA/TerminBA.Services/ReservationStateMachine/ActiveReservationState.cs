using EasyNetQ;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using TerminBA.Models.Execptions;
using TerminBA.Models.Messages;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;

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
            entity.CancellationDeadline = reservationStart.AddHours(-hours);

            await ValidateReservationInsertAsync(request);
            //await SendEmailAsync(request);

            await _context.Reservations.AddAsync(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<ReservationResponse>(entity);
        }

        public override async Task<ReservationResponse> UpdateAsync(int id, ReservationUpdateRequest request)
        {
            var entity = await _context.Reservations
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
                throw new UserException("Reservation was not found");

            await ValidateReservationUpdateAsync(entity, request);

            _mapper.Map(request, entity);
            entity.Status = nameof(ActiveReservationState); 

            await _context.SaveChangesAsync();

            return _mapper.Map<ReservationResponse>(entity);
        }

        public override async Task<CancellationResponse> CancelAsync(int id)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var entity = await _context.Reservations
                    .FirstOrDefaultAsync(r => r.Id == id);

                if (entity == null)
                    throw new UserException("Reservation was not found");

                if (string.Equals(entity.PaymentMethod, "Stripe", StringComparison.OrdinalIgnoreCase))
                {
                    var payment = await _context.Payments
                        .OrderByDescending(p => p.CreatedAt)
                        .FirstOrDefaultAsync(p => p.ReservationId == id && p.Status == TerminBA.Services.Enums.PaymentStatus.Paid);

                    if (payment != null && (!entity.CancellationDeadline.HasValue || entity.CancellationDeadline >= DateTime.Now))
                    {
                        var stripeService = _serviceProvider.GetRequiredService<TerminBA.Services.Interfaces.IStripePaymentService>();
                        var refundId = await stripeService.CreateRefundAsync(payment.StripePaymentIntentId, payment.Amount);
                        
                        payment.StripeRefundId = refundId;
                        payment.RefundAmount = payment.Amount;
                        payment.RefundRequestedAt = DateTime.Now;
                        payment.Status = TerminBA.Services.Enums.PaymentStatus.RefundPending;

                        entity.Status = nameof(CanceledWithRefundReservationState);
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

                entity.CanceledAt = DateTime.Now;
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return new CancellationResponse
                {
                    ReservationState = entity.Status,
                    RefundIssued = entity.Status == nameof(CanceledWithRefundReservationState),
                    RefundAmount = entity.PaymentMethod == "Stripe" && entity.Status == nameof(CanceledWithRefundReservationState) ? entity.Price : null,
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

            var allSlots = await TimeSlotHelper.GenerateTimeSlots(request.FacilityId, request.ReservationDate, _context);

            var slot = allSlots.FirstOrDefault(t =>
                t.Start == request.StartTime.ToTimeSpan() &&
                t.End == request.EndTime.ToTimeSpan());

            if (slot == default)
                throw new UserException("Can't pick a non existing time slot.");

            var hasConflict = await _context.Reservations
                .AnyAsync(r => r.FacilityId == request.FacilityId
                               && r.ReservationDate == request.ReservationDate
                               && r.Id != entity.Id
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

        private static void ValidateReservationNotInPast(DateOnly reservationDate, TimeOnly reservationStartTime)
        {
            var now = DateTime.Now;
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
