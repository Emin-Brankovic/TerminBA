using MapsterMapper;
using System;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Services.Database;

namespace TerminBA.Services.PostStateMachine
{
    public class FinishedPostState : BasePostState
    {
        public FinishedPostState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper)
            : base(serviceProvider, context, mapper)
        {
        }
    }
}
