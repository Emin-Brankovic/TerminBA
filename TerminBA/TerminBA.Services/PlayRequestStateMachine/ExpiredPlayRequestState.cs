using MapsterMapper;
using System;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.PlayRequestStateMachine
{
    public class ExpiredPlayRequestState : BasePlayRequestState
    {
        public ExpiredPlayRequestState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper, INotificationsHubService notificationsHubService)
            : base(serviceProvider, context, mapper, notificationsHubService)
        {
        }
    }
}
