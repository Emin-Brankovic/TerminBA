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

        public override async Task<ReservationResponse> CancelAsync(int id)
        {
            var entity = await _context.Reservations
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
                throw new UserException("Reservation was not found");

            entity.Status = nameof(CanceledReservationState);

            await _context.SaveChangesAsync();

            return _mapper.Map<ReservationResponse>(entity);
        }

        private async Task ValidateReservationInsertAsync(ReservationInsertRequest request)
        {
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

            var expectedPrice = GetExpectedPriceForInsert(request, facility);

            if (request.Price != expectedPrice)
                throw new UserException($"Invalid price for selected time slot and reservation date.");
        }


        private async Task ValidateReservationUpdateAsync(Reservation entity, ReservationUpdateRequest request)
        {
            var allSlots = await TimeSlotHelper.GenerateTimeSlots(entity.FacilityId, request.ReservationDate, _context);

            var slot = allSlots.FirstOrDefault(t =>
                t.Start == request.StartTime.ToTimeSpan() &&
                t.End == request.EndTime.ToTimeSpan());

            if (slot == default)
                throw new UserException("Can't pick a non existing time slot.");

            var hasConflict = await _context.Reservations
                .AnyAsync(r => r.FacilityId == entity.FacilityId
                               && r.ReservationDate == request.ReservationDate
                               && r.Id != entity.Id
                               && request.StartTime < r.EndTime
                               && request.EndTime > r.StartTime
                               && r.Status == nameof(ActiveReservationState));

            if (hasConflict)
                throw new UserException("Can't pick a booked time slot.");

            var facility = await _context.Facilities
                .Include(f => f.DynamicPrices)
                .FirstOrDefaultAsync(f => f.Id == entity.FacilityId);

            if (facility == null)
                throw new UserException("Facility not found.");

            var expectedPrice = GetExpectedPriceForInsert(request, facility);

            if (request.Price != expectedPrice)
                throw new UserException($"Invalid price for selected time slot and reservation date.");
        }

        private decimal GetExpectedPriceForInsert(dynamic request, Facility facility)
        {
            var durationHours = (decimal)facility.Duration.TotalHours;

            if (!facility.IsDynamicPricing)
            {
                if (!facility.StaticPrice.HasValue)
                    throw new UserException("Static price is not configured for this facility.");

                return decimal.Round(facility.StaticPrice.Value * durationHours, 2, MidpointRounding.AwayFromZero);
            }

            var dynamicPrice = facility.DynamicPrices
                .FirstOrDefault(dp =>
                    TimeSlotHelper.IsInDayRange(request.ReservationDate.DayOfWeek, dp.StartDay, dp.EndDay)
                    && TimeSlotHelper.IsWithinValidityPeriod(request.ReservationDate, dp.ValidFrom, dp.ValidTo)
                    && dp.StartTime <= request.StartTime
                    && dp.EndTime >= request.EndTime)
                ?? throw new UserException("No price is found for selected time and date");

            return decimal.Round(dynamicPrice.PricePerHour * durationHours, 2, MidpointRounding.AwayFromZero);
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
