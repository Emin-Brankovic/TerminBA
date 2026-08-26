using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
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
using TerminBA.Services.PlayRequestStateMachine;
namespace TerminBA.Services.PostStateMachine
{
    public class PlayerSearchPostState : BasePostState
    {
        private readonly INotificationsHubService _notificationsHubService;

        public PlayerSearchPostState(
            IServiceProvider serviceProvider, 
            TerminBaContext context, 
            IMapper mapper,
            INotificationsHubService notificationsHubService) 
            : base(serviceProvider, context, mapper)
        {
            _notificationsHubService = notificationsHubService;
        }


        public  async override Task<PlayRequestResponse> SendPlayRequestAsync(PlayRequestInsertRequest request)
        {
            PlayRequest entity = new PlayRequest();
            entity = _mapper.Map(request, entity);

            await ValidatePlayRequestInsertAsync(request);

            await _context.PlayRequests.AddAsync(entity);

            await _context.SaveChangesAsync();

            var post = await _context.Posts
                .Include(p => p.Reservation)
                .FirstOrDefaultAsync(p => p.Id == request.PostId);

            var requester = await _context.Users.FindAsync(request.RequesterId);

            if (post?.Reservation?.UserId != null)
            {
                var payload = new
                {
                    type = "join_request_received",
                    requestId = entity.Id,
                    postId = entity.PostId,
                    fromUserId = request.RequesterId,
                    fromUserDisplayName = requester != null ? $"{requester.FirstName} {requester.LastName}" : "A user",
                    createdAt = entity.DateOfRequest?.ToString("o"),
                    messagePreview = entity.RequestText ?? ""
                };
                var userId = post.Reservation.UserId ?? 0;
                await _notificationsHubService.SendJoinRequestNotificationAsync(userId, payload);
            }

            return _mapper.Map<PlayRequestResponse>(entity);
        }


        public async override Task<PostResponse> UpdateAsync(int id, PostUpdateRequest request)
        {
            var entity = await _context.Posts.FindAsync(id);

            if (entity == null)
                throw new UserException("Post was not found");

            if (request.NumberOfPlayersWanted < entity.NumberOfPlayersWanted
                && entity.NumberOfPlayersFound == request.NumberOfPlayersWanted)
                entity.PostState = nameof(PlayerFoundPostState);

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

        private async Task ValidatePlayRequestInsertAsync(PlayRequestInsertRequest request)
        {

            var post = await _context.Posts
                .Include(p=>p.Reservation)
                .FirstOrDefaultAsync(p=>request.PostId==p.Id);

            if (post?.Reservation?.UserId == request.RequesterId)
                throw new UserException("You cannot send a request to your own post.");

            var duplicate = await _context.PlayRequests
                .AnyAsync(pr =>
                    pr.PostId == request.PostId &&
                    pr.RequesterId == request.RequesterId &&
                    pr.PlayRequestState == nameof(PendingPlayRequestState));

            if (duplicate)
                throw new UserException("You already have a pending request for this post.");
        }
    }
}
