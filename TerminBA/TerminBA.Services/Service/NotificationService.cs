using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class NotificationService : INotificationService
    {
        private readonly TerminBaContext _context;
        private readonly IMapper _mapper;
        private readonly IAuthService<AccountBase> _authService;

        public NotificationService(TerminBaContext context, IMapper mapper, IAuthService<AccountBase> authService)
        {
            _context = context;
            _mapper = mapper;
            _authService = authService;
        }

        public async Task<PagedResult<NotificationResponse>> GetAsync(NotificationSearchObject search)
        {
            int userId = int.Parse(_authService.GetUserId());

            var cancelQuery = _context.CancelationNotifications
                .Where(n => n.PostOwnerId == userId)
                .Select(n => new NotificationResponse
                {
                    Id = n.Id,
                    PostOwnerId = n.PostOwnerId,
                    ReservationId = n.ReservationId,
                    RequesterName = n.RequesterName,
                    FacilityName = n.FacilityName,
                    Date = n.DateCancelled,
                    IsSeen = n.IsSeen,
                    Reason = n.Reason,
                    Type = "Cancelation"
                });

            var updateQuery = _context.UpdateNotifications
                .Where(n => n.PostOwnerId == userId)
                .Select(n => new NotificationResponse
                {
                    Id = n.Id,
                    PostOwnerId = n.PostOwnerId,
                    ReservationId = n.ReservationId,
                    RequesterName = n.RequesterName,
                    FacilityName = n.FacilityName,
                    Date = n.DateUpdated,
                    IsSeen = n.IsSeen,
                    Reason = n.Message,
                    Type = "Update"
                });

            var combinedQuery = cancelQuery.Union(updateQuery).OrderByDescending(n => n.Date);

            var totalCount = await combinedQuery.CountAsync();

            int pageSize = search.PageSize ?? 10;
            int page = search.Page ?? 1;

            var items = await combinedQuery
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            // Populate Reservations
            var reservationIds = items.Select(i => i.ReservationId).Distinct().ToList();
            if (reservationIds.Any())
            {
                var reservations = await _context.Reservations
                    .Where(r => reservationIds.Contains(r.Id))
                    .ToDictionaryAsync(r => r.Id, r => _mapper.Map<ReservationResponse>(r));

                foreach (var item in items)
                {
                    if (reservations.TryGetValue(item.ReservationId, out var res))
                    {
                        item.Reservation = res;
                    }
                }
            }

            return new PagedResult<NotificationResponse>
            {
                Items = items,
                Count = totalCount
            };
        }

        public async Task<int> GetUnseenCountAsync()
        {
            int userId = int.Parse(_authService.GetUserId());

            var cancelCount = await _context.CancelationNotifications
                .Where(n => n.PostOwnerId == userId && !n.IsSeen)
                .CountAsync();

            var updateCount = await _context.UpdateNotifications
                .Where(n => n.PostOwnerId == userId && !n.IsSeen)
                .CountAsync();

            return cancelCount + updateCount;
        }

        public async Task MarkAsSeenAsync(int id, string type)
        {
            if (type == "Cancelation")
            {
                var notification = await _context.CancelationNotifications.FindAsync(id);
                if (notification != null && !notification.IsSeen)
                {
                    notification.IsSeen = true;
                    await _context.SaveChangesAsync();
                }
            }
            else if (type == "Update")
            {
                var notification = await _context.UpdateNotifications.FindAsync(id);
                if (notification != null && !notification.IsSeen)
                {
                    notification.IsSeen = true;
                    await _context.SaveChangesAsync();
                }
            }
        }

        public async Task MarkAsSeenMultipleAsync(List<NotificationIdentifier> items)
        {
            var cancelIds = items.Where(i => i.Type == "Cancelation").Select(i => i.Id).ToList();
            var updateIds = items.Where(i => i.Type == "Update").Select(i => i.Id).ToList();

            if (cancelIds.Any())
            {
                var cancels = await _context.CancelationNotifications.Where(n => cancelIds.Contains(n.Id)).ToListAsync();
                foreach (var n in cancels) n.IsSeen = true;
            }

            if (updateIds.Any())
            {
                var updates = await _context.UpdateNotifications.Where(n => updateIds.Contains(n.Id)).ToListAsync();
                foreach (var n in updates) n.IsSeen = true;
            }

            await _context.SaveChangesAsync();
        }

        public async Task DeleteMultipleAsync(List<NotificationIdentifier> items)
        {
            var cancelIds = items.Where(i => i.Type == "Cancelation").Select(i => i.Id).ToList();
            var updateIds = items.Where(i => i.Type == "Update").Select(i => i.Id).ToList();

            if (cancelIds.Any())
            {
                var cancels = await _context.CancelationNotifications.Where(n => cancelIds.Contains(n.Id)).ToListAsync();
                _context.CancelationNotifications.RemoveRange(cancels);
            }

            if (updateIds.Any())
            {
                var updates = await _context.UpdateNotifications.Where(n => updateIds.Contains(n.Id)).ToListAsync();
                _context.UpdateNotifications.RemoveRange(updates);
            }

            await _context.SaveChangesAsync();
        }
    }
}
