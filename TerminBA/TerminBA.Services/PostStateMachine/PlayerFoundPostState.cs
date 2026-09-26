using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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
