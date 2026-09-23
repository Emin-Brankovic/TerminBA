using CloudinaryDotNet;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Exceptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;
using TerminBA.Services.PlayRequestStateMachine;
using TerminBA.Services.ReservationStateMachine;

namespace TerminBA.Services.Service
{
    public class FacilityReviewService : BaseCRUDService<FacilityReviewResponse, FacilityReview, FacilityReviewSearchObject, FacilityReviewInsertRequest, FacilityReviewUpdateRequest>, IFacilityReviewService
    {
        private readonly Dictionary<string, string> _currentUser;
        private readonly IAuthService<AccountBase> _authService;

        public FacilityReviewService(TerminBaContext context, IMapper mapper, IAuthService<AccountBase>  authService) : base(context, mapper)
        {
            this._authService = authService;
            _currentUser = _authService.GetCurrentUser();
        }

        public override IQueryable<FacilityReview> ApplyFilter(IQueryable<FacilityReview> query, FacilityReviewSearchObject search)
        {
            if (_currentUser["userRole"] == "Sport center")
                search.SportCenterId = int.Parse(_authService.GetUserId());

            if (search.SportCenterId.HasValue)
                query = query.Where(fr => fr.Facility!.SportCenterId == search.SportCenterId.Value);

            if (!string.IsNullOrWhiteSpace(search.SortOption))
            {
                switch (search.SortOption)
                {
                    case "newest":
                        query = query.OrderByDescending(fr => fr.RatingDate);
                        break;
                    case "oldest":
                        query = query.OrderBy(fr => fr.RatingDate);
                        break;
                    case "topRated":
                        query = query.OrderByDescending(fr => fr.RatingNumber);
                        break;
                    case "lowRated":
                        query = query.OrderBy(fr => fr.RatingNumber);
                        break;
                }
            }



            if (search.UserId.HasValue)
                query = query.Where(fr => fr.UserId == search.UserId.Value);

            if (search.FacilityId.HasValue)
                query = query.Where(fr => fr.FacilityId == search.FacilityId.Value);

            if (search.ReservationId.HasValue)
                query = query.Where(fr => fr.ReservationId == search.ReservationId.Value);


            if (search.MinRating.HasValue)
                query = query.Where(fr => fr.RatingNumber >= search.MinRating.Value);

            if (search.MaxRating.HasValue)
                query = query.Where(fr => fr.RatingNumber <= search.MaxRating.Value);

            if (search.RatingDateFrom.HasValue)
                query = query.Where(fr => fr.RatingDate >= DateOnly.FromDateTime(search.RatingDateFrom.Value));

            if (search.RatingDateTo.HasValue)
                query = query.Where(fr => fr.RatingDate <= DateOnly.FromDateTime(search.RatingDateTo.Value));

            if (!string.IsNullOrWhiteSpace(search.FTS))
                query = query
                    .Where(fr =>
                    (!string.IsNullOrWhiteSpace(fr.Comment) && fr.Comment.ToLower().Contains(search.FTS.ToLower())) ||
                    (!string.IsNullOrWhiteSpace(fr.User.FirstName) && fr.User.FirstName.ToLower().Contains(search.FTS.ToLower())) ||
                    (!string.IsNullOrWhiteSpace(fr.User.LastName) && fr.User.FirstName.ToLower().Contains(search.FTS.ToLower())) ||
                    (!string.IsNullOrWhiteSpace(fr.User.Username) && fr.User.FirstName.ToLower().Contains(search.FTS.ToLower())));


            return query;
        }

        public override IQueryable<FacilityReview> ApplyIncludes(IQueryable<FacilityReview> query)
        {
            query = query
                .Include(fr => fr.User)
                .Include(fr => fr.Facility);

            return query;
        }


        protected override async Task BeforeInsert(FacilityReview entity, FacilityReviewInsertRequest request)
        {
            var userId = int.Parse(_authService.GetUserId());
            entity.UserId = userId; 

            if (request.ReservationId.HasValue)
            {
                var reservation = await _context.Reservations
                    .FirstOrDefaultAsync(r => r.Id == request.ReservationId.Value);

                if (reservation == null)
                    throw new UserException("Reservation not found.");

                if (reservation.Status != nameof(CompletedReservationState))
                    throw new UserException("You can only leave a review for a completed reservation.");

                var endDateTime = reservation.ReservationDate.ToDateTime(reservation.EndTime);
                if (TimeHelper.GetFacilityNow() < endDateTime)
                    throw new UserException("You can only leave a review after the appointment has ended.");

                var alreadyReviewed = await _context.FacilityReviews
                    .AnyAsync(fr => fr.ReservationId == request.ReservationId.Value && fr.UserId == userId);
                if (alreadyReviewed)
                    throw new UserException("You have already submitted a review for this reservation.");

                bool isParticipant = reservation.UserId == userId ||
                    await _context.PlayRequests.AnyAsync(pr => pr.Post!.ReservationId == request.ReservationId.Value && pr.RequesterId == userId && pr.PlayRequestState == nameof(AcceptedPlayRequestState));

                if (!isParticipant)
                    throw new UserException("You must be a participant in this reservation to leave a review.");

                if (!request.FacilityId.HasValue)
                {
                    entity.FacilityId = reservation.FacilityId;
                }
                else if (request.FacilityId.Value != reservation.FacilityId)
                {
                    throw new UserException("The supplied FacilityId does not match the reservation's facility.");
                }
            }

            await base.BeforeInsert(entity, request);
        }

        public async Task<double> GetAverageRatingAsync(int facilityId)
        {
            var avg = await _context.FacilityReviews
                .Where(r => r.FacilityId == facilityId)
                .Select(r => (double?)r.RatingNumber)
                .AverageAsync() ?? 0.0;

            return Math.Round(avg, 1);
        }

        public async Task<PagedResult<FacilityReviewResponse>> GetMyReviewsAsync(FacilityReviewSearchObject search)
        {
            search.UserId = int.Parse(_authService.GetUserId());
            return await base.GetAsync(search);
        }

        protected override Task BeforeUpdate(FacilityReview entity, FacilityReviewUpdateRequest request)
        {
            var currentUserId = int.Parse(_authService.GetUserId());
            request.UserId = currentUserId;
            if (entity.UserId != currentUserId)
                throw new UserException("Editing of other reviews isn't possible");

            return Task.CompletedTask;
        }

        protected override async Task BeforeDelete(FacilityReview entity)
        {
            var currentUserRole = _currentUser["userRole"];
            var currentUserId = int.Parse(_authService.GetUserId());

            if (currentUserRole == "User")
            {
                if (entity.UserId != currentUserId)
                    throw new UserException("You can only delete your own facility reviews.");
            }
            else if (currentUserRole == "Sport center")
            {
                var facility = await _context.Facilities.FindAsync(entity.FacilityId);
                if (facility == null || facility.SportCenterId != currentUserId)
                    throw new UserException("You can only delete reviews on your own facilities.");
            }
        }
    }
}
