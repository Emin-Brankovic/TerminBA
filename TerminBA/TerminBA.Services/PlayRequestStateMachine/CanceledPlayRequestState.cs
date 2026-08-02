using MapsterMapper;
using System;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.PlayRequestStateMachine
{
    public class CanceledPlayRequestState : BasePlayRequestState
    {
        public CanceledPlayRequestState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper, INotificationsHubService notificationsHubService)
            : base(serviceProvider, context, mapper, notificationsHubService)
        {
        }
    }
}
