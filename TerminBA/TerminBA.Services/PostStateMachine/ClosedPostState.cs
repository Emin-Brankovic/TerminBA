using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
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

    }
}
