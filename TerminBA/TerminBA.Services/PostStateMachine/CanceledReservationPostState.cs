using MapsterMapper;
using System;
using System.Threading.Tasks;
using TerminBA.Models.Exceptions;
using TerminBA.Models.Model;
using TerminBA.Services.Database;

namespace TerminBA.Services.PostStateMachine
{
    public class CanceledReservationPostState : BasePostState
    {
        public CanceledReservationPostState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper)
            : base(serviceProvider, context, mapper)
        {
        }
    }
}
