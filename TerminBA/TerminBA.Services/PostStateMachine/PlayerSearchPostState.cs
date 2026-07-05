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

        public async override Task<PlayRequestResponse> RespondToPlayRequestAsync(int id, bool response)
        {
            var playRequest = await _context.PlayRequests
                .Include(pr=>pr.Post)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (playRequest == null)
                throw new UserException("The request does not exist");

            if (response)
            {
                if (playRequest?.Post?.NumberOfPlayersFound == playRequest?.Post?.NumberOfPlayersWanted)
                    throw new UserException("All players found");

                if((playRequest?.Post?.NumberOfPlayersFound + 1) == playRequest?.Post?.NumberOfPlayersWanted)
                {
                    playRequest!.Post!.PostState=nameof(PlayerFoundPostState);
                }

                playRequest!.Post!.NumberOfPlayersFound += 1;

            }

            playRequest.isAccepted = response;
            playRequest.DateOfResponse = DateTime.Now;

            await _context.SaveChangesAsync();

            var postOwner = playRequest.Post?.Reservation?.User ?? await _context.Users.FindAsync(playRequest.Post?.Reservation?.UserId);
            var ownerName = postOwner != null ? $"{postOwner.FirstName} {postOwner.LastName}" : "A user";

            var payload = new
            {
                type = "join_request_responded",
                requestId = playRequest.Id,
                postId = playRequest.PostId,
                isAccepted = response,
                fromUserId = postOwner?.Id,
                fromUserDisplayName = ownerName,
                respondedAt = playRequest.DateOfResponse?.ToString("o")
            };
            
            await _notificationsHubService.SendJoinRequestRespondedNotificationAsync(playRequest.RequesterId, payload);

            return _mapper.Map<PlayRequestResponse>(playRequest);
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

        public async override Task<PlayRequestResponse> CancelAsync(int playRequestId)
        {
            var request = await _context.PlayRequests
                .Include(pr => pr.Post)
                .FirstOrDefaultAsync(pr => pr.Id == playRequestId);

            if (request == null)
                throw new UserException("Request not found");

            request.isAccepted = false;

            var post = request.Post;

            if(post!.NumberOfPlayersFound > 0)
                post!.NumberOfPlayersFound--;

            await _context.SaveChangesAsync();

            // TODO: Send notifications here

            return _mapper.Map<PlayRequestResponse>(request);
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

            // Prevent duplicate active/pending requests
            var duplicate = await _context.PlayRequests
                .AnyAsync(pr =>
                    pr.PostId == request.PostId &&
                    pr.RequesterId == request.RequesterId &&
                    pr.isAccepted == null); // null = pending

            if (duplicate)
                throw new UserException("You already have a pending request for this post.");
        }
    }
}
