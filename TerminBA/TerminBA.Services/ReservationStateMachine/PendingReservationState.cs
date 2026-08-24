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
using TerminBA.Services.PlayRequestStateMachine;
using TerminBA.Services.PostStateMachine;

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
            var reservationStartUtc = TimeHelper.ConvertToUtc(reservationStart);
            entity.CancellationDeadline = reservationStartUtc.AddHours(-hours);

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
                var userId=entity.UserId ?? throw new UserException("UserId is null");
                //await SendEmailAsync(entity.Id);
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
                    foreach (var ar in acceptedRequests)
                    {
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
            var now = TimeHelper.GetFacilityNow();
            var today = DateOnly.FromDateTime(now);
            if (request.ReservationDate < today || (request.ReservationDate == today && request.StartTime.ToTimeSpan() <= now.TimeOfDay))
                throw new UserException("Can't make a reservation in the past.");
        }

        private async Task SendEmailAsync(int reservationId)
        {
            var bus = _serviceProvider.GetService<IBus>()
                ?? throw new UserException("Message bus is not configured");

            await Helpers.EmailPublisherHelper.PublishReservationCreatedEmailAsync(bus, _context, reservationId);
        }
    }
}
