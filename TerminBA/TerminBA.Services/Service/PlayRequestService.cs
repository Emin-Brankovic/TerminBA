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

namespace TerminBA.Services.Service
{
    public class PlayRequestService : BaseCRUDService<PlayRequestResponse, PlayRequest, PlayRequestSearchObject, PlayRequestInsertRequest, PlayRequestUpdateRequest>, IPlayRequestService
    {
        protected readonly BasePostState _basePostState;
        private readonly IAuthService<AccountBase> _authService;
        private readonly Dictionary<string, string> _currentUser;

        public PlayRequestService(TerminBaContext context, IMapper mapper, BasePostState basePostState, IAuthService<AccountBase> authService) : base(context, mapper)
        {
            this._basePostState = basePostState;
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

        public async Task<PlayRequestResponse> RespondToPlayRequestAsync(int id,bool response)
        {
            var entity = await _context.PlayRequests
                .Include(pr=>pr.Post)
                .FirstOrDefaultAsync(pr=>pr.Id==id);

            var baseState = _basePostState.GetPostState(entity!.Post!.PostState);

            var result = await baseState.RespondToPlayRequestAsync(id, response);

            return result;
        }

        public override IQueryable<PlayRequest> ApplyFilter(IQueryable<PlayRequest> query, PlayRequestSearchObject search)
        {
            if (search.PostId.HasValue)
                query = query.Where(pr => pr.PostId == search.PostId.Value);

            if (search.RequesterId.HasValue)
                query = query.Where(pr => pr.RequesterId == search.RequesterId.Value);

            if (search.RecipientUserId.HasValue)
                query=query.Where(pr=>pr.Post!.Reservation!.UserId== search.RecipientUserId.Value);

            if(search.DateOfRequest.HasValue)
                query=query.Where(pr=>pr.DateOfRequest!.Value.Date== search.DateOfRequest.Value.Date);

            if (!string.IsNullOrEmpty(search.Status))
            {
                if (search.Status.ToLower() == "pending")
                    query = query.Where(pr => pr.isAccepted == null);
                else if (search.Status.ToLower() == "accepted")
                    query = query.Where(pr => pr.isAccepted == true);
                else if (search.Status.ToLower() == "denied")
                    query = query.Where(pr => pr.isAccepted == false);
            }

            query = query.OrderByDescending(pr => pr.DateOfRequest);

            return query;
        }

        public async Task<PlayRequestResponse> CancelAsync(int playRequestId)
        {
            var entity = await _context.PlayRequests
                .Include(pr => pr.Post)
                .FirstOrDefaultAsync(pr => pr.Id == playRequestId);

            var baseState = _basePostState.GetPostState(entity!.Post!.PostState);

            return await baseState.CancelAsync(playRequestId);

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
                .Where(pr => pr.RequesterId == userId && !pr.IsSeenByRequester && pr.isAccepted != null)
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
