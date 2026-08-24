using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.PlayRequestStateMachine
{
    public class BasePlayRequestState
    {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly TerminBaContext _context;
        protected readonly IMapper _mapper;
        protected readonly INotificationsHubService _notificationsHubService;

        public BasePlayRequestState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper, INotificationsHubService notificationsHubService)
        {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;
            _notificationsHubService = notificationsHubService;
        }

        public virtual Task<PlayRequestResponse> AcceptAsync(int id, int currentUserId)
        {
            throw new UserException("Method not allowed in this state.");
        }

        public virtual Task<PlayRequestResponse> RejectAsync(int id, string reason, int currentUserId)
        {
            throw new UserException("Method not allowed in this state.");
        }

        public virtual Task<PlayRequestResponse> CancelAsync(int id, string? reason, int currentUserId)
        {
            throw new UserException("Method not allowed in this state.");
        }

        public BasePlayRequestState GetState(string currentStateName)
        {
            switch (currentStateName)
            {
                case nameof(PendingPlayRequestState):
                    return _serviceProvider.GetService<PendingPlayRequestState>()!;
                case nameof(AcceptedPlayRequestState):
                    return _serviceProvider.GetService<AcceptedPlayRequestState>()!;
                case nameof(RejectedPlayRequestState):
                    return _serviceProvider.GetService<RejectedPlayRequestState>()!;
                case nameof(CanceledPlayRequestState):
                    return _serviceProvider.GetService<CanceledPlayRequestState>()!;
                case nameof(ExpiredPlayRequestState):
                    return _serviceProvider.GetService<ExpiredPlayRequestState>()!;
                default:
                    throw new UserException($"State {currentStateName} is not defined");
            }
        }
    }
}
