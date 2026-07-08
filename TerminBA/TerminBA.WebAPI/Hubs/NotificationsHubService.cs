using Microsoft.AspNetCore.SignalR;
using TerminBA.Services.Interfaces;

namespace TerminBA.WebAPI.Hubs
{
    public class NotificationsHubService : INotificationsHubService
    {
        private readonly IHubContext<NotificationsHub> _hubContext;

        public NotificationsHubService(IHubContext<NotificationsHub> hubContext)
        {
            _hubContext = hubContext;
        }

        public async Task SendJoinRequestNotificationAsync(int postOwnerUserId, object payload)
        {
            await _hubContext.Clients.User(postOwnerUserId.ToString()).SendAsync("join_request_received", payload);
        }

        public async Task SendJoinRequestRespondedNotificationAsync(int requesterUserId, object payload)
        {
            await _hubContext.Clients.User(requesterUserId.ToString()).SendAsync("join_request_responded", payload);
        }

        public async Task SendJoinRequestCancelledNotificationAsync(int postOwnerUserId, object payload)
        {
            await _hubContext.Clients.User(postOwnerUserId.ToString()).SendAsync("join_request_cancelled", payload);
        }
    }
}
