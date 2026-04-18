using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Services.Database;

namespace TerminBA.Services.ReservationStateMachine
{
    public class CanceledReservationState : BaseReservationState
    {
        public CanceledReservationState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper)
            : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Reservations
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
                return false;

            _context.Reservations.Remove(entity);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}
