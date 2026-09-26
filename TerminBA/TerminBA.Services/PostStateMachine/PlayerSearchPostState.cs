using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Exceptions;
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
            var authService = _serviceProvider.GetService<TerminBA.Services.Interfaces.IAuthService<AccountBase>>();
            var requesterId = int.Parse(authService.GetUserId());
            entity.RequesterId = requesterId;

            await ValidatePlayRequestInsertAsync(request, requesterId);

            await _context.PlayRequests.AddAsync(entity);

            await _context.SaveChangesAsync();

            var post = await _context.Posts
                .Include(p => p.Reservation)
                .FirstOrDefaultAsync(p => p.Id == request.PostId);

            var requester = await _context.Users.FindAsync(requesterId);

            if (post?.Reservation?.UserId != null)
            {
                var payload = new
                {
                    type = "join_request_received",
                    requestId = entity.Id,
                    postId = entity.PostId,
                    fromUserId = requesterId,
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
            if (request.NumberOfPlayersWanted < 1)
            {
                throw new UserException("Number of players wanted must be at least 1.");
            }

            var entity = await _context.Posts
                .Include(p => p.Reservation)
                    .ThenInclude(r => r.Facility)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (entity == null)
                throw new UserException("Post was not found");

            if (entity.Reservation?.Facility != null && request.NumberOfPlayersWanted > entity.Reservation.Facility.MaxCapacity)
            {
                throw new UserException($"Number of players wanted cannot exceed the facility's maximum capacity ({entity.Reservation.Facility.MaxCapacity}).");
            }

            if (request.NumberOfPlayersWanted < entity.NumberOfPlayersFound)
                throw new UserException("Cannot decrease wanted players below already accepted players.");

            if (request.NumberOfPlayersWanted == entity.NumberOfPlayersFound)
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

        private async Task ValidatePlayRequestInsertAsync(PlayRequestInsertRequest request, int requesterId)
        {

            var post = await _context.Posts
                .Include(p=>p.Reservation)
                .FirstOrDefaultAsync(p=>request.PostId==p.Id);

            if (post?.Reservation?.UserId == requesterId)
                throw new UserException("You cannot send a request to your own post.");

            var duplicate = await _context.PlayRequests
                .AnyAsync(pr =>
                    pr.PostId == request.PostId &&
                    pr.RequesterId == requesterId &&
                    (pr.PlayRequestState == nameof(PendingPlayRequestState) || 
                    pr.PlayRequestState == nameof(AcceptedPlayRequestState)));

            if (duplicate)
                throw new UserException("You already have a pending request for this post.");
        }
    }
}
