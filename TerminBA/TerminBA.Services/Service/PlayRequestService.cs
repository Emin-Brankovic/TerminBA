using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;
using TerminBA.Services.PostStateMachine;
using TerminBA.Services.PlayRequestStateMachine;

namespace TerminBA.Services.Service
{
    public class PlayRequestService : BaseCRUDService<PlayRequestResponse, PlayRequest, PlayRequestSearchObject, PlayRequestInsertRequest, PlayRequestUpdateRequest>, IPlayRequestService
    {
        protected readonly BasePostState _basePostState;
        protected readonly BasePlayRequestState _basePlayRequestState;
        private readonly IAuthService<AccountBase> _authService;
        private readonly Dictionary<string, string> _currentUser;

        public PlayRequestService(TerminBaContext context, IMapper mapper, BasePostState basePostState, BasePlayRequestState basePlayRequestState, IAuthService<AccountBase> authService) : base(context, mapper)
        {
            this._basePostState = basePostState;
            this._basePlayRequestState = basePlayRequestState;
            this._authService = authService;
            _currentUser = _authService.GetCurrentUser();
        }

        public async override Task<PlayRequestResponse> CreateAsync(PlayRequestInsertRequest request)
        {
            var postEntity = await _context.Posts
                .FirstOrDefaultAsync(p => p.Id == request.PostId);

            var baseState = _basePostState.GetPostState(postEntity!.PostState);

            var result = await baseState.SendPlayRequestAsync(request);

            return result;
        }

        public async Task<PlayRequestResponse> RespondToPlayRequestAsync(int id, PlayRequestRespondRequest request)
        {
            var entity = await _context.PlayRequests
                .FirstOrDefaultAsync(pr=>pr.Id==id);

            if (entity == null) throw new UserException("Request not found");

            var baseState = _basePlayRequestState.GetState(entity.PlayRequestState);
            
            var currentUserId = int.Parse(_authService.GetUserId());

            if (request.IsAccepted)
            {
                return await baseState.AcceptAsync(id, currentUserId);
            }
            else
            {
                return await baseState.RejectAsync(id, request.Reason ?? string.Empty, currentUserId);
            }
        }

        public override IQueryable<PlayRequest> ApplyFilter(IQueryable<PlayRequest> query, PlayRequestSearchObject search)
        {
            if (search.ReservationId.HasValue)
                query = query.Where(pr => pr.Post!.ReservationId == search.ReservationId.Value);

            if (search.PostId.HasValue)
                query = query.Where(pr => pr.PostId == search.PostId.Value);

            if (search.RequesterId.HasValue)
                query = query.Where(pr => pr.RequesterId == search.RequesterId.Value);

            if (search.RecipientUserId.HasValue)
                query=query.Where(pr=>pr.Post!.Reservation!.UserId == search.RecipientUserId.Value);

            if (search.DateOfRequest.HasValue)
            {
                var targetDate = search.DateOfRequest.Value.Date;
                query = query.Where(pr => pr.DateOfRequest >= targetDate && pr.DateOfRequest < targetDate.AddDays(1));
            }

            if (!string.IsNullOrEmpty(search.PlayRequestState))
            {
                if (search.PlayRequestState.ToLower() == "pending")
                    query = query.Where(pr => pr.PlayRequestState == "PendingPlayRequestState");
                else if (search.PlayRequestState.ToLower() == "accepted")
                    query = query.Where(pr => pr.PlayRequestState == "AcceptedPlayRequestState");
                else if (search.PlayRequestState.ToLower() == "rejected")
                    query = query.Where(pr => pr.PlayRequestState == "RejectedPlayRequestState");
                else if (search.PlayRequestState.ToLower() == "canceled")
                    query = query.Where(pr => pr.PlayRequestState == "CanceledPlayRequestState");
                else if (search.PlayRequestState.ToLower() == "expired")
                    query = query.Where(pr => pr.PlayRequestState == "ExpiredPlayRequestState");
                else
                    query = query.Where(pr => pr.PlayRequestState == search.PlayRequestState);
            }

            query = query.OrderByDescending(pr => pr.DateOfRequest);

            return query;
        }

        public async Task<PlayRequestResponse> CancelAsync(int id, PlayRequestCancelRequest request)
        {
            var entity = await _context.PlayRequests
                .FirstOrDefaultAsync(pr => pr.Id == id);

            if (entity == null) throw new UserException("Request not found");

            var baseState = _basePlayRequestState.GetState(entity.PlayRequestState);
            
            var currentUserId = int.Parse(_authService.GetUserId());

            return await baseState.CancelAsync(id, request.Reason, currentUserId);
        }

        public override IQueryable<PlayRequest> ApplyIncludes(IQueryable<PlayRequest> query)
        {
            query = query
                .Include(pr => pr.Post)
                    .ThenInclude(p => p.Reservation)
                        .ThenInclude(r => r.User)
                .Include(pr => pr.Post)
                    .ThenInclude(p => p.Reservation)
                        .ThenInclude(r => r.Facility)
                .Include(pr => pr.Requester);

            return query;
        }

        public async Task<int> GetUnseenRequestsCountAsync()
        {
            var userId = int.Parse(_authService.GetUserId());
            return await _context.PlayRequests
                .Include(pr => pr.Post)
                .ThenInclude(p => p.Reservation)
                .Where(pr => pr.Post!.Reservation!.UserId == userId && !pr.IsSeenByOwner)
                .CountAsync();
        }

        public async Task<PlayRequestResponse> MarkRequestAsSeenAsync(int requestId)
        {
            var userId = int.Parse(_authService.GetUserId());
            var request = await _context.PlayRequests
                .Include(pr => pr.Post)
                .ThenInclude(p => p.Reservation)
                .FirstOrDefaultAsync(pr => pr.Id == requestId);

            if (request == null)
                throw new UserException("Request not found");

            if (request.Post?.Reservation?.UserId != userId)
                throw new UserException("You are not authorized to perform this action.");

            if (!request.IsSeenByOwner)
            {
                request.IsSeenByOwner = true;
                await _context.SaveChangesAsync();
            }

            return _mapper.Map<PlayRequestResponse>(request);
        }
        public async Task<int> GetUnseenResponsesCountAsync()
        {
            var userId = int.Parse(_authService.GetUserId());
            return await _context.PlayRequests
                .Where(pr => pr.RequesterId == userId && !pr.IsSeenByRequester && pr.PlayRequestState != "PendingPlayRequestState")
                .CountAsync();
        }

        public async Task<PlayRequestResponse> MarkResponseAsSeenAsync(int requestId)
        {
            var userId = int.Parse(_authService.GetUserId());
            var request = await _context.PlayRequests
                .FirstOrDefaultAsync(pr => pr.Id == requestId);

            if (request == null)
                throw new UserException("Request not found");

            if (request.RequesterId != userId)
                throw new UserException("You are not authorized to perform this action.");

            if (!request.IsSeenByRequester)
            {
                request.IsSeenByRequester = true;
                await _context.SaveChangesAsync();
            }

            return _mapper.Map<PlayRequestResponse>(request);
        }

    }
}
