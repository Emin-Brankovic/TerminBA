using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Services.Database;

namespace TerminBA.Services.ReservationStateMachine
{
    public class CompletedReservationState : BaseReservationState
    {
        public CompletedReservationState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper)
    : base(serviceProvider, context, mapper) { }

        // Optional: allow delete if your business rules allow it
        public override async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Reservations.FirstOrDefaultAsync(r => r.Id == id);
            if (entity == null) return false;

            _context.Reservations.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
