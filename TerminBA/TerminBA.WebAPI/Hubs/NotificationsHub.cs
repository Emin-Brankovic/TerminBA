using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace TerminBA.WebAPI.Hubs
{
    [Authorize]
    public class NotificationsHub : Hub
    {
        // Clients.User(userId) will be used to send targeted notifications
        // Connection mapping is handled automatically by SignalR if we use the ClaimTypes.NameIdentifier

        public override async Task OnConnectedAsync()
        {
            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            await base.OnDisconnectedAsync(exception);
        }
    }
}
