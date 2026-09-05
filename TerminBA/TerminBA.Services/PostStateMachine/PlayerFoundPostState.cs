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


        public async override Task<PostResponse> UpdateAsync(int id,PostUpdateRequest request)
        {
            var entity = await _context.Posts.FindAsync(id);

            if (entity == null)
                throw new UserException("Post was not found");

            if (request.NumberOfPlayersWanted < entity.NumberOfPlayersFound)
                throw new UserException("Cannot decrease wanted players below already accepted players.");

            if (request.NumberOfPlayersWanted > entity.NumberOfPlayersWanted)
                entity.PostState = nameof(PlayerSearchPostState);

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
