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
    public class DraftPostState : BasePostState
    {
        public DraftPostState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<PostResponse> CreateAsync(PostInsertRequest request)
        {
            Post entity = new Post();
            entity = _mapper.Map(request, entity);

            entity.PostState = nameof(PlayerSearchPostState);

            await ValidatePostInsertAsync(request);

            await _context.Posts.AddAsync(entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<PostResponse>(entity);
        }

        private async Task ValidatePostInsertAsync(PostInsertRequest request)
        {
            var reservation = await _context.Reservations
                .FirstOrDefaultAsync(r => r.Id == request.ReservationId);

            if (reservation == null)
                throw new UserException("Reservation was not found.");

            var currentDate = DateOnly.FromDateTime(DateTime.UtcNow);
            var currentTime = TimeOnly.FromDateTime(DateTime.UtcNow);

            if (currentDate > reservation.ReservationDate ||
                (currentDate == reservation.ReservationDate && currentTime > reservation.StartTime))
            {
                throw new UserException("Cannot create a post for a reservation that already started or finished.");
            }
        }
    }
}
