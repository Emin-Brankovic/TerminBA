using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Services.Database;

namespace TerminBA.Services.PostStateMachine
{
    public class ClosedPostState : BasePostState
    {
        public ClosedPostState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public async override Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Posts.FindAsync(id);

            if (entity == null)
                return false;

            //await BeforeDelete(entity);

            _context.Posts.Remove(entity);

            await _context.SaveChangesAsync();

            return true;
        }

        public override async Task<PostResponse> ReopenAsync(int id)
        {
            var entity = await _context.Posts.FindAsync(id);
            if (entity == null)
                throw new UserException("Post not found");

            if (entity.NumberOfPlayersFound < entity.NumberOfPlayersWanted)
            {
                entity.PostState = nameof(PlayerSearchPostState);
            }
            else
            {
                entity.PostState = nameof(PlayerFoundPostState);
            }

            await _context.SaveChangesAsync();
            return _mapper.Map<PostResponse>(entity);
        }
    }
}
