using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using TerminBA.Models.Exceptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Services.Database;
using Microsoft.EntityFrameworkCore;
using TerminBA.Services.Helpers;

namespace TerminBA.Services.ReservationStateMachine
{
    public class BaseReservationState
    {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly TerminBaContext _context;
        protected readonly IMapper _mapper;

        public BaseReservationState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper)
        {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;
        }

        public virtual Task<ReservationResponse> CreateAsync(ReservationInsertRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<ReservationResponse> UpdateAsync(int id, ReservationUpdateRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<bool> DeleteAsync(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<CancellationResponse> CancelAsync(int id, string reason)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<ReservationResponse> ConfirmOnSitePaymentAsync(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<ReservationResponse> ConfirmPaymentAsync(int id, string paymentMethod)
        {
            throw new UserException("Method not allowed");
        }

        protected async Task ValidateReservationCoreAsync(
            int facilityId,
            DateOnly reservationDate,
            TimeOnly startTime,
            TimeOnly endTime,
            decimal price,
            int? chosenSportId,
            int? excludedReservationId = null)
        {
            var now = TimeHelper.GetFacilityNow();
            var today = DateOnly.FromDateTime(now);

            if (reservationDate < today)
            {
                throw new UserException("Can't make a reservation in the past.");
            }

            if (reservationDate == today && startTime.ToTimeSpan() <= now.TimeOfDay)
            {
                throw new UserException("Can't make a reservation in the past.");
            }

            var timeSlots = await TimeSlotHelper.GenerateTimeSlots(facilityId, reservationDate, _context);
            var exists = timeSlots.Any(t =>
                t.Start == startTime.ToTimeSpan() &&
                t.End == endTime.ToTimeSpan());

            if (!exists)
                throw new UserException("Can't pick a non existing time slot");

            var facility = await _context.Facilities
                .Include(f => f.DynamicPrices)
                .Include(f => f.AvailableSports)
                .FirstOrDefaultAsync(f => f.Id == facilityId);

            if (facility == null)
                throw new UserException("Facility not found.");

            if (chosenSportId.HasValue && !facility.AvailableSports.Any(s => s.Id == chosenSportId.Value))
            {
                throw new UserException("Selected sport is not available at this facility.");
            }

            var conflictQuery = _context.Reservations
                .Where(r => r.FacilityId == facilityId
                            && r.ReservationDate == reservationDate
                            && startTime < r.EndTime
                            && endTime > r.StartTime
                            && r.Status == nameof(ActiveReservationState));

            if (excludedReservationId.HasValue)
            {
                conflictQuery = conflictQuery.Where(r => r.Id != excludedReservationId.Value);
            }

            var hasConflict = await conflictQuery.AnyAsync();

            if (hasConflict)
                throw new UserException("Can't pick a booked time slot.");

            var expectedPrice = DynamicPriceHelper.GetExpectedPrice(
                facility,
                reservationDate,
                startTime,
                endTime);

            if (price != expectedPrice)
                throw new UserException($"Invalid price for selected time slot and reservation date.");
        }

        public BaseReservationState GetReservationState(string? currentReservationStateName)
        {
            switch (currentReservationStateName)
            {
                case nameof(PendingReservationState):
                    return _serviceProvider.GetService<PendingReservationState>()!;
                case nameof(ActiveReservationState):
                case "Confirmed":
                    return _serviceProvider.GetService<ActiveReservationState>()!;
                case nameof(CompletedReservationState):
                    return _serviceProvider.GetService<CompletedReservationState>()!;
                case nameof(CanceledReservationState):
                    return _serviceProvider.GetService<CanceledReservationState>()!;
                case nameof(CanceledWithRefundReservationState):
                    return _serviceProvider.GetService<CanceledWithRefundReservationState>()!;
                case nameof(CanceledWithoutRefundReservationState):
                    return _serviceProvider.GetService<CanceledWithoutRefundReservationState>()!;
                default:
                    throw new UserException($"State {currentReservationStateName} is not defined");
            }
        }
    }
}
