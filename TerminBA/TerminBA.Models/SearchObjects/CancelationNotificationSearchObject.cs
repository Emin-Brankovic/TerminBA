namespace TerminBA.Models.SearchObjects
{
    public class CancelationNotificationSearchObject : BaseSearchObject
    {
        public int? PostOwnerId { get; set; }
        public bool? IsSeen { get; set; }
    }
}
