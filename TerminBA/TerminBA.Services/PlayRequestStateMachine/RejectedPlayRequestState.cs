using MapsterMapper;
using System;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.PlayRequestStateMachine
{
    public class RejectedPlayRequestState : BasePlayRequestState
    {
        public RejectedPlayRequestState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper, INotificationsHubService notificationsHubService)
            : base(serviceProvider, context, mapper, notificationsHubService)
        {
        }
    }
}
