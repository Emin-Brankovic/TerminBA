using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;

namespace TerminBA.Services.Interfaces
{
    public interface IPlayRequestService : IBaseCRUDService<PlayRequestResponse, PlayRequestSearchObject, PlayRequestInsertRequest, PlayRequestUpdateRequest>
    {
        Task<PlayRequestResponse> RespondToPlayRequestAsync(int id, bool response);
        public Task<PlayRequestResponse> CancelAsync(int playRequestId);
        Task<int> GetUnseenRequestsCountAsync();
        Task<PlayRequestResponse> MarkRequestAsSeenAsync(int requestId);
        Task<int> GetUnseenResponsesCountAsync();
        Task<PlayRequestResponse> MarkResponseAsSeenAsync(int requestId);
    }
}
