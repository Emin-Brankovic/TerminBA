namespace TerminBA.Services.Interfaces
{
    public interface INotificationsHubService
    {
        Task SendJoinRequestNotificationAsync(int postOwnerUserId, object payload);
        Task SendJoinRequestRespondedNotificationAsync(int requesterUserId, object payload);
        Task SendJoinRequestCancelledNotificationAsync(int postOwnerUserId, object payload);
    }
}
