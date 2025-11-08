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

namespace TerminBA.Services.Service
{
    public class PlayRequestService : BaseCRUDService<PlayRequestResponse, PlayRequest, PlayRequestSearchObject, PlayRequestInsertRequest, PlayRequestUpdateRequest>, IPlayRequestService
    {
        public PlayRequestService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<PlayRequestResponse> PlayRequestResponse(int id,bool response)
        {
           var playRequest=await _context.PlayRequests.FirstOrDefaultAsync(x => x.Id == id);

            if (playRequest == null)
                throw new UserException("The request does not exist");

            playRequest.isAccepted= response;
            playRequest.DateOfResponse= DateTime.Now;

            await _context.SaveChangesAsync();

            return MapToResponse(playRequest);
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

        public override IQueryable<PlayRequest> ApplyIncludes(IQueryable<PlayRequest> query)
        {
            query = query
                .Include(pr => pr.Post)
                .Include(pr => pr.Requester);

            return query;
        }
    }
}
