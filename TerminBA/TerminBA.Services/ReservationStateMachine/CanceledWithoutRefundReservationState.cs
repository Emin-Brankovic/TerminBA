using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Exceptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Services.Database;

namespace TerminBA.Services.ReservationStateMachine
{
    public class CanceledWithoutRefundReservationState : BaseReservationState
    {
        public CanceledWithoutRefundReservationState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper)
            : base(serviceProvider, context, mapper)
        {
        }
    }
}
