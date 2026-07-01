using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Services.Database;

namespace TerminBA.Services.ReservationStateMachine
{
    public class PendingReservationState : BaseReservationState
    {
        public PendingReservationState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper)
            : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<ReservationResponse> CreateAsync(ReservationInsertRequest request)
        {
            var entity = new Reservation();
            entity = _mapper.Map(request, entity);
            entity.Status = nameof(PendingReservationState);

            var facility = await _context.Facilities.Include(f => f.SportCenter).FirstOrDefaultAsync(f => f.Id == request.FacilityId);
            var hours = facility?.SportCenter?.CancellationDeadlineHours ?? 24;
            var reservationStart = request.ReservationDate.ToDateTime(request.StartTime);
            entity.CancellationDeadline = reservationStart.AddHours(-hours);

            await ValidateReservationInsertAsync(request);

            await _context.Reservations.AddAsync(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<ReservationResponse>(entity);
        }

        public override async Task<ReservationResponse> UpdateAsync(int id, ReservationUpdateRequest request)
        {
            var entity = await _context.Reservations.FirstOrDefaultAsync(r => r.Id == id);
            if (entity == null)
                throw new UserException("Reservation was not found");

            if (request.Status == nameof(ActiveReservationState))
            {
                entity.Status = nameof(ActiveReservationState);
                await _context.SaveChangesAsync();
                return _mapper.Map<ReservationResponse>(entity);
            }

            _mapper.Map(request, entity);
            await _context.SaveChangesAsync();
            return _mapper.Map<ReservationResponse>(entity);
        }

        public override async Task<CancellationResponse> CancelAsync(int id)
        {
            var entity = await _context.Reservations.FirstOrDefaultAsync(r => r.Id == id);
            if (entity == null)
                throw new UserException("Reservation was not found");

            entity.Status = nameof(CanceledWithoutRefundReservationState);
            entity.CanceledAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return new CancellationResponse
            {
                ReservationState = entity.Status,
                RefundIssued = false
            };
        }

        public override async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Reservations.FirstOrDefaultAsync(r => r.Id == id);
            if (entity == null)
                return false;

            _context.Reservations.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        private async Task ValidateReservationInsertAsync(ReservationInsertRequest request)
        {
            var now = DateTime.Now;
            var today = DateOnly.FromDateTime(now);
            if (request.ReservationDate < today || (request.ReservationDate == today && request.StartTime.ToTimeSpan() <= now.TimeOfDay))
                throw new UserException("Can't make a reservation in the past.");
        }
    }
}
