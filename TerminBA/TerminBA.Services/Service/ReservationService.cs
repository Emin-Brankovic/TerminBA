using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Exceptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;
using TerminBA.Services.ReservationStateMachine;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace TerminBA.Services.Service
{
    public class ReservationService : BaseCRUDService<ReservationResponse, Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>, IReservationService
    {
        protected readonly BaseReservationState _baseReservationState;
        private readonly Dictionary<string, string> _currentUser;
        private readonly IAuthService<AccountBase> _authService;

        public ReservationService(TerminBaContext context, IMapper mapper, BaseReservationState baseReservationState,IAuthService<AccountBase> authService) : base(context, mapper)
        {
            _baseReservationState = baseReservationState;

            this._authService = authService;
            _currentUser = _authService.GetCurrentUser();
        }

        public override async Task<ReservationResponse> CreateAsync(ReservationInsertRequest request)
        {
            bool isSportCenter = _currentUser != null && _currentUser.TryGetValue("userRole", out var role) && role == "Sport center";

            string initialState = (request.PaymentMethod == Models.Enums.PaymentMethod.Stripe || !isSportCenter)
                ? nameof(PendingReservationState)
                : nameof(ActiveReservationState);

            var baseState = _baseReservationState.GetReservationState(initialState);

            return await baseState.CreateAsync(request);
        }

        public override async Task<ReservationResponse?> UpdateAsync(int id, ReservationUpdateRequest request)
        {
            var entity = await _context.Reservations
                .Include(r => r.Facility)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
                return null;

            if (_currentUser["userRole"] == "User" && entity.UserId != int.Parse(_authService.GetUserId()))
            {
                throw new UserException("You can only modify your own reservations.");
            }
            if (_currentUser["userRole"] == "Sport center" && entity.Facility.SportCenterId != int.Parse(_authService.GetUserId()))
            {
                throw new UserException("You can only modify reservations for your own facilities.");
            }

            var baseState = _baseReservationState.GetReservationState(entity.Status);

            return await baseState.UpdateAsync(id, request);
        }

        public override async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Reservations.FirstOrDefaultAsync(r => r.Id == id);
            
            if (entity == null)
                return false;

            var baseState = _baseReservationState.GetReservationState(entity.Status);

            return await baseState.DeleteAsync(id);
        }

        public async Task<CancellationResponse> CancelAsync(int id, ReservationCancelRequest request)
        {
            var entity = await _context.Reservations
                .Include(r => r.Facility)
                .FirstOrDefaultAsync(r => r.Id == id)
                ?? throw new UserException("Reservation was not found");

            if (_currentUser["userRole"] == "User" && entity.UserId != int.Parse(_authService.GetUserId()))
            {
                throw new UserException("You can only cancel your own reservations.");
            }
            if (_currentUser["userRole"] == "Sport center" && entity.Facility.SportCenterId != int.Parse(_authService.GetUserId()))
            {
                throw new UserException("You can only cancel reservations for your own facilities.");
            }

            var baseState = _baseReservationState.GetReservationState(entity.Status);

            return await baseState.CancelAsync(id, request.Reason ?? string.Empty);
        }

        public async Task<ReservationResponse> ConfirmOnSitePaymentAsync(int id)
        {
            var entity = await _context.Reservations
                .Include(r => r.Facility)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
                throw new UserException("Reservation was not found");

            if (_currentUser["userRole"] == "User" && entity.UserId != int.Parse(_authService.GetUserId()))
            {
                throw new UserException("You can only modify your own reservations.");
            }
            if (_currentUser["userRole"] == "Sport center" && entity.Facility.SportCenterId != int.Parse(_authService.GetUserId()))
            {
                throw new UserException("You can only modify reservations for your own facilities.");
            }

            var baseState = _baseReservationState.GetReservationState(entity.Status);
            return await baseState.ConfirmPaymentAsync(id, TerminBA.Models.Enums.PaymentMethod.OnSite.ToString());
        }

        public override IQueryable<Reservation> ApplyFilter(IQueryable<Reservation> query, ReservationSearchObject search)
        {

            if (_currentUser["userRole"] == "Sport center")
                search.SportCenterId = int.Parse(_authService.GetUserId());

            if (_currentUser["userRole"] == "User")
                search.UserId = int.Parse(_authService.GetUserId());

            if (search.SportCenterId.HasValue)
                query = query.Where(r => r.Facility.SportCenterId == search.SportCenterId);

            if (search.UserId.HasValue)
                query = query.Where(r => r.UserId == search.UserId.Value);

            if (search.FacilityId.HasValue)
                query = query.Where(r => r.FacilityId == search.FacilityId.Value);

            if (!string.IsNullOrEmpty(search.Status))
            {
                if (search.Status.ToLower() == "upcoming")
                {
                    var now = DateTime.UtcNow;
                    var dateOnly = DateOnly.FromDateTime(now);
                    var timeOnly = TimeOnly.FromDateTime(now);
                    query = query.Where(r => string.Equals(r.Status, nameof(ActiveReservationState)));
                }
                else if (search.Status.ToLower() == "past")
                {
                    var now = DateTime.UtcNow;
                    var dateOnly = DateOnly.FromDateTime(now);
                    var timeOnly = TimeOnly.FromDateTime(now);
                    query = query.Where(r => string.Equals(r.Status, nameof(CompletedReservationState)));
                }
                else
                {
                    query = query.Where(r => r.Status!.ToLower() == search.Status.ToLower());
                }
            }

            if (search.ChosenSportId.HasValue)
                query = query.Where(r => r.ChosenSportId == search.ChosenSportId.Value);

            if (search.ReservationDate.HasValue)
                query = query.Where(r => r.ReservationDate == search.ReservationDate.Value);

            if(!string.IsNullOrEmpty(search.FacilityName))
                query = query.Where(r => r.Facility.Name.Contains(search.FacilityName));

            if (search.SortByChosenTimeSlot)
            {
                var desc = string.Equals(search.TimeSlotSortDirection, "desc", StringComparison.OrdinalIgnoreCase);

                query = desc
                    ? query.OrderByDescending(r => r.ReservationDate).ThenByDescending(r => r.StartTime)
                    : query.OrderBy(r => r.ReservationDate).ThenBy(r => r.StartTime);
            }
            else
            {
                query = query.OrderByDescending(r => r.Id);
            }

            return query;
        }

        public override IQueryable<Reservation> ApplyIncludes(IQueryable<Reservation> query)
        {
            query = query
                .Include(r => r.Facility)
                    .ThenInclude(f => f.Photos)
                .Include(r => r.Facility)
                    .ThenInclude(f => f.ReviewsReceived)
                .Include(r => r.Facility)
                    .ThenInclude(f => f.SportCenter)
                        .ThenInclude(sc => sc.City)
                .Include(r => r.Facility)
                    .ThenInclude(f => f.TurfType)
                .Include(r => r.User)
                .Include(r => r.ChosenSport)
                .Include(r => r.Payments)
                .Include(r => r.Posts)
                .AsSplitQuery();

            return query;
        }

    }
}







