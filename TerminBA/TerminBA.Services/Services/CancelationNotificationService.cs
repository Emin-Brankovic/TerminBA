using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;
using TerminBA.Services.Service;

namespace TerminBA.Services.Services
{
    public class CancelationNotificationService : BaseCRUDService<CancelationNotificationResponse, CancelationNotification, CancelationNotificationSearchObject, object, object>, ICancelationNotificationService
    {
        private readonly IAuthService<User> _authService;

        public CancelationNotificationService(TerminBaContext context, IMapper mapper, IAuthService<User> authService) : base(context, mapper)
        {
            _authService = authService;
        }

        public override IQueryable<CancelationNotification> ApplyFilter(IQueryable<CancelationNotification> query, CancelationNotificationSearchObject search)
        {
            var userIdStr = _authService.GetUserId();
            if (int.TryParse(userIdStr, out int userId))
            {
                query = query.Where(x => x.PostOwnerId == userId);
            }

            if (search.IsSeen.HasValue)
            {
                query = query.Where(x => x.IsSeen == search.IsSeen);
            }

            // Order by most recent first
            query = query.OrderByDescending(x => x.DateCancelled);

            return base.ApplyFilter(query, search);
        }

        public override IQueryable<CancelationNotification> ApplyIncludes(IQueryable<CancelationNotification> query)
        {
            return query.Include(x => x.Reservation);
        }

        public async Task MarkAsSeenAsync(int id)
        {
            var notification = await _context.CancelationNotifications.FindAsync(id);
            if (notification != null)
            {
                notification.IsSeen = true;
                await _context.SaveChangesAsync();
            }
        }

        public async Task<int> GetUnseenCountAsync()
        {
            var userIdStr = _authService.GetUserId();
            if (int.TryParse(userIdStr, out int userId))
            {
                return await _context.CancelationNotifications
                    .Where(x => x.PostOwnerId == userId && !x.IsSeen)
                    .CountAsync();
            }
            return 0;
        }
    }
}
