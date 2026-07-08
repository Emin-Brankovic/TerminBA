using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.PostStateMachine
{
    public class PlayerFoundPostState : BasePostState
    {
        private readonly INotificationsHubService _notificationsHubService;

        public PlayerFoundPostState(
            IServiceProvider serviceProvider, 
            TerminBaContext context, 
            IMapper mapper,
            INotificationsHubService notificationsHubService) 
            : base(serviceProvider, context, mapper)
        {
            _notificationsHubService = notificationsHubService;
        }

        public async override Task<PlayRequestResponse> CancelAsync(int playRequestId)
        {
            var request = await _context.PlayRequests
                .Include(pr => pr.Post)
                .ThenInclude(p => p.Reservation)
                .ThenInclude(r => r.Facility)
                .Include(pr => pr.Requester)
                .FirstOrDefaultAsync(pr => pr.Id == playRequestId);

            if (request == null)
                throw new UserException("Request not found");

            bool wasAccepted = request.isAccepted == true;

            _context.PlayRequests.Remove(request);

            var post = request.Post;

            if (wasAccepted && post!.NumberOfPlayersFound > 0)
                post!.NumberOfPlayersFound--;

            if (post.NumberOfPlayersFound < post.NumberOfPlayersWanted)
            {
                post.PostState = nameof(PlayerSearchPostState);
            }

            if (wasAccepted && post?.Reservation?.UserId != null)
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

            if (wasAccepted && post?.Reservation?.UserId != null)
            {
                var payload = new
                {
                    type = "join_request_cancelled",
                    requestId = request.Id,
                    postId = request.PostId,
                    fromUserId = request.RequesterId,
                    fromUserDisplayName = request.Requester != null ? $"{request.Requester.FirstName} {request.Requester.LastName}" : "A user",
                    cancelledAt = DateTime.Now.ToString("o")
                };

                await _notificationsHubService.SendJoinRequestCancelledNotificationAsync(post.Reservation.UserId.Value, payload);
            }

            return _mapper.Map<PlayRequestResponse>(request);
        }

        public async override Task<PostResponse> UpdateAsync(int id,PostUpdateRequest request)
        {
            var entity = await _context.Posts.FindAsync(id);

            if (entity == null)
                throw new UserException("Post was not found");

            if(request.NumberOfPlayersWanted>entity.NumberOfPlayersWanted)
                entity.PostState=nameof(PlayerSearchPostState);

            if (request.NumberOfPlayersWanted < entity.NumberOfPlayersWanted
                && entity.NumberOfPlayersFound > request.NumberOfPlayersWanted)
                throw new UserException("Can't decrease number of wanted players, remove an accepted");

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<PostResponse>(entity);
        }

        public async override Task<PostResponse> ClosePost(Post post)
        {
            if (post == null)
                throw new UserException("Post was not found");

            post.PostState = nameof(ClosedPostState);

            await _context.SaveChangesAsync();

            return _mapper.Map<PostResponse>(post);
        }
    }
}
