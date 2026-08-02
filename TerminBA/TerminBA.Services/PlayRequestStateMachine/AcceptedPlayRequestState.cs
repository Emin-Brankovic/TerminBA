using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;
using TerminBA.Services.PostStateMachine;

namespace TerminBA.Services.PlayRequestStateMachine
{
    public class AcceptedPlayRequestState : BasePlayRequestState
    {
        public AcceptedPlayRequestState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper, INotificationsHubService notificationsHubService)
            : base(serviceProvider, context, mapper, notificationsHubService)
        {
        }

        public override async Task<PlayRequestResponse> CancelAsync(int id, string? reason, int currentUserId)
        {
            var request = await _context.PlayRequests
                .Include(pr => pr.Post)
                .ThenInclude(p => p.Reservation)
                .ThenInclude(r => r.Facility)
                .Include(pr => pr.Requester)
                .FirstOrDefaultAsync(pr => pr.Id == id);

            if (request == null)
                throw new UserException("Request not found");

            if (request.RequesterId != currentUserId)
                throw new UserException("You are not authorized to cancel this request.");

            // Update PlayRequest state
            request.PlayRequestState = nameof(CanceledPlayRequestState);
            request.CanceledAt = DateTime.UtcNow;
            request.CanceledById = currentUserId;
            request.Reason = reason;

            // Handle Post logic
            var post = request.Post;

            if (post!.NumberOfPlayersFound > 0)
                post!.NumberOfPlayersFound--;

            if (post.NumberOfPlayersFound < post.NumberOfPlayersWanted)
            {
                post.PostState = nameof(PlayerSearchPostState);
            }

            // Create notification for post owner
            if (post?.Reservation?.UserId != null)
            {
                var notification = new CancelationNotification
                {
                    PostOwnerId = post.Reservation.UserId.Value,
                    ReservationId = post.Reservation.Id,
                    RequesterName = request.Requester != null ? $"{request.Requester.FirstName} {request.Requester.LastName}" : "A user",
                    FacilityName = post.Reservation.Facility?.Name ?? "Unknown facility",
                    DateCancelled = DateTime.Now,
                    IsSeen = false
                };
                _context.CancelationNotifications.Add(notification);
            }

            await _context.SaveChangesAsync();

            // Send Real-time notification
            if (post?.Reservation?.UserId != null)
            {
                var payload = new
                {
                    type = "join_request_cancelled",
                    requestId = request.Id,
                    postId = request.PostId,
                    fromUserId = request.RequesterId,
                    fromUserDisplayName = request.Requester != null ? $"{request.Requester.FirstName} {request.Requester.LastName}" : "A user",
                    cancelledAt = DateTime.UtcNow.ToString("o"),
                    reason = reason
                };

                await _notificationsHubService.SendJoinRequestCancelledNotificationAsync(post.Reservation.UserId.Value, payload);
            }

            return _mapper.Map<PlayRequestResponse>(request);
        }
    }
}
