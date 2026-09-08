using System.Collections.Generic;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.SearchObjects;

namespace TerminBA.Services.Interfaces
{
    public interface INotificationService 
    {
        Task<PagedResult<NotificationResponse>> GetAsync(NotificationSearchObject search);
        Task MarkAsSeenAsync(int id, string type);
        Task<int> GetUnseenCountAsync();
        Task MarkAsSeenMultipleAsync(List<TerminBA.Models.Request.NotificationIdentifier> items);
        Task DeleteMultipleAsync(List<TerminBA.Models.Request.NotificationIdentifier> items);
    }
}
