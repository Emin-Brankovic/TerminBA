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

        public PlayRequestService(TerminBaContext context, IMapper mapper, BasePostState basePostState) : base(context, mapper)
        {
            this._basePostState = basePostState;
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
                .Include(pr => pr.Requester);

            return query;
        }

    }
}
