using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Services.Database;

namespace TerminBA.Services.ReservationStateMachine
{
    public class BaseReservationState
    {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly TerminBaContext _context;
        protected readonly IMapper _mapper;

        public BaseReservationState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper)
        {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;
        }

        public virtual Task<ReservationResponse> CreateAsync(ReservationInsertRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<ReservationResponse> UpdateAsync(int id, ReservationUpdateRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<bool> DeleteAsync(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<CancellationResponse> CancelAsync(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<ReservationResponse> ActivateAsync(int id)
        {
            throw new UserException("Method not allowed");
        }

        public BaseReservationState GetReservationState(string? currentReservationStateName)
        {
            switch (currentReservationStateName)
            {
                case nameof(PendingReservationState):
                    return _serviceProvider.GetService<PendingReservationState>()!;
                case nameof(ActiveReservationState):
                case "Confirmed":
                    return _serviceProvider.GetService<ActiveReservationState>()!;
                case nameof(CompletedReservationState):
                    return _serviceProvider.GetService<CompletedReservationState>()!;
                case nameof(CanceledReservationState):
                    return _serviceProvider.GetService<CanceledReservationState>()!;
                case nameof(CanceledWithRefundReservationState):
                    return _serviceProvider.GetService<CanceledWithRefundReservationState>()!;
                case nameof(CanceledWithoutRefundReservationState):
                    return _serviceProvider.GetService<CanceledWithoutRefundReservationState>()!;
                default:
                    throw new UserException($"State {currentReservationStateName} is not defined");
            }
        }
    }
}
