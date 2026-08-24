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
    public class PendingPlayRequestState : BasePlayRequestState
    {
        public PendingPlayRequestState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper, INotificationsHubService notificationsHubService)
            : base(serviceProvider, context, mapper, notificationsHubService)
        {
        }

        public override async Task<PlayRequestResponse> AcceptAsync(int id, int currentUserId)
        {
            var playRequest = await _context.PlayRequests
                .Include(pr => pr.Post)
                .ThenInclude(p => p.Reservation)
                .ThenInclude(r => r.User)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (playRequest == null)
                throw new UserException("The request does not exist");

            var postState = playRequest.Post?.PostState;
            if (postState == nameof(ClosedPostState) || postState == nameof(FinishedPostState) || postState == nameof(CanceledReservationPostState))
                throw new UserException("Cannot respond to play requests while the post is closed, finished, or canceled.");

            var postOwnerId = playRequest.Post?.Reservation?.UserId;
            if (postOwnerId != currentUserId)
                throw new UserException("You are not authorized to respond to this request.");

            // Update Post
            if (playRequest.Post?.NumberOfPlayersFound == playRequest.Post?.NumberOfPlayersWanted)
                throw new UserException("All players found");

            if ((playRequest.Post?.NumberOfPlayersFound + 1) == playRequest.Post?.NumberOfPlayersWanted)
            {
                playRequest.Post.PostState = nameof(PlayerFoundPostState);
            }

            playRequest.Post!.NumberOfPlayersFound += 1;

            // Update PlayRequest
            playRequest.PlayRequestState = nameof(AcceptedPlayRequestState);
            playRequest.DateOfResponse = DateTime.UtcNow;
            playRequest.RespondedById = currentUserId;
            playRequest.Reason = null;

            await _context.SaveChangesAsync();

            // Notification
            var postOwner = playRequest.Post.Reservation?.User ?? await _context.Users.FindAsync(postOwnerId);
            var ownerName = postOwner != null ? $"{postOwner.FirstName} {postOwner.LastName}" : "A user";

            var payload = new
            {
                type = "join_request_responded",
                requestId = playRequest.Id,
                postId = playRequest.PostId,
                isAccepted = true,
                fromUserId = postOwner?.Id,
                fromUserDisplayName = ownerName,
                respondedAt = playRequest.DateOfResponse?.ToString("o")
            };

            await _notificationsHubService.SendJoinRequestRespondedNotificationAsync(playRequest.RequesterId, payload);

            return _mapper.Map<PlayRequestResponse>(playRequest);
        }

        public override async Task<PlayRequestResponse> RejectAsync(int id, string reason, int currentUserId)
        {
            if (string.IsNullOrWhiteSpace(reason))
                throw new UserException("Reason is required when rejecting a request.");

            var playRequest = await _context.PlayRequests
                .Include(pr => pr.Post)
                .ThenInclude(p => p.Reservation)
                .ThenInclude(r => r.User)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (playRequest == null)
                throw new UserException("The request does not exist");

            var postState = playRequest.Post?.PostState;
            if (postState == nameof(ClosedPostState) || postState == nameof(FinishedPostState) || postState == nameof(CanceledReservationPostState))
                throw new UserException("Cannot respond to play requests while the post is closed, finished, or canceled.");

            var postOwnerId = playRequest.Post?.Reservation?.UserId;
            if (postOwnerId != currentUserId)
                throw new UserException("You are not authorized to respond to this request.");

            playRequest.PlayRequestState = nameof(RejectedPlayRequestState);
            playRequest.DateOfResponse = DateTime.UtcNow;
            playRequest.RespondedById = currentUserId;
            playRequest.Reason = reason;

            await _context.SaveChangesAsync();

            var postOwner = playRequest.Post.Reservation?.User ?? await _context.Users.FindAsync(postOwnerId);
            var ownerName = postOwner != null ? $"{postOwner.FirstName} {postOwner.LastName}" : "A user";

            var payload = new
            {
                type = "join_request_responded",
                requestId = playRequest.Id,
                postId = playRequest.PostId,
                isAccepted = false,
                reason = reason,
                fromUserId = postOwner?.Id,
                fromUserDisplayName = ownerName,
                respondedAt = playRequest.DateOfResponse?.ToString("o")
            };

            await _notificationsHubService.SendJoinRequestRespondedNotificationAsync(playRequest.RequesterId, payload);

            return _mapper.Map<PlayRequestResponse>(playRequest);
        }

        public override async Task<PlayRequestResponse> CancelAsync(int id, string? reason, int currentUserId)
        {
            var request = await _context.PlayRequests
                .Include(pr => pr.Post)
                .ThenInclude(p => p.Reservation)
                .Include(pr => pr.Requester)
                .FirstOrDefaultAsync(pr => pr.Id == id);

            if (request == null)
                throw new UserException("Request not found");

            if (request.RequesterId != currentUserId)
                throw new UserException("You are not authorized to cancel this request.");

            request.PlayRequestState = nameof(CanceledPlayRequestState);
            request.CanceledAt = DateTime.UtcNow;
            request.CanceledById = currentUserId;
            request.Reason = reason;

            await _context.SaveChangesAsync();

            var post = request.Post;
            if (post?.Reservation?.UserId != null)
            {
                var payload = new
                {
                    type = "join_request_cancelled",
                    requestId = request.Id,
                    postId = request.PostId,
                    fromUserId = request.RequesterId,
                    fromUserDisplayName = request.Requester != null ? $"{request.Requester.FirstName} {request.Requester.LastName}" : "A user",
                    cancelledAt = request.CanceledAt?.ToString("o"),
                    reason = reason
                };

                await _notificationsHubService.SendJoinRequestCancelledNotificationAsync(post.Reservation.UserId.Value, payload);
            }

            return _mapper.Map<PlayRequestResponse>(request);
        }
    }
}
