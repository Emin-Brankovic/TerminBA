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

namespace TerminBA.Services.PostStateMachine
{
    public class PlayerFoundPostState : BasePostState
    {
        public PlayerFoundPostState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
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

            if (post!.NumberOfPlayersFound > 0)
                post!.NumberOfPlayersFound--;

            if (post.NumberOfPlayersFound < post.NumberOfPlayersWanted)
            {
                post.PostState = nameof(PlayerSearchPostState);
            }

            await _context.SaveChangesAsync();

            // TODO: Send notifications here

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
