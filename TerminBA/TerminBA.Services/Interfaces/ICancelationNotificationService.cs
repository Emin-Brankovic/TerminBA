using System.Collections.Generic;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.SearchObjects;

namespace TerminBA.Services.Interfaces
{
    public interface ICancelationNotificationService : IBaseCRUDService<CancelationNotificationResponse, CancelationNotificationSearchObject, object, object>
    {
        Task MarkAsSeenAsync(int id);
        Task<int> GetUnseenCountAsync();
        Task MarkAsSeenMultipleAsync(List<int> ids);
        Task DeleteMultipleAsync(List<int> ids);
    }
}
