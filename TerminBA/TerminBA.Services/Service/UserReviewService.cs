using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class UserReviewService : BaseCRUDService<UserReviewResponse, UserReview, UserReviewSearchObject, UserReviewInsertRequest, UserReviewUpdateRequest>, IUserReviewService
    {
        private readonly IAuthService<AccountBase> _authService;
        private readonly Dictionary<string, string> _currentUser;

        public UserReviewService(TerminBaContext context, IMapper mapper, IAuthService<AccountBase> authService) : base(context, mapper)
        {
            this._authService = authService;
            _currentUser = _authService.GetCurrentUser();
        }

        public override IQueryable<UserReview> ApplyFilter(IQueryable<UserReview> query, UserReviewSearchObject search)
        {
            if (_currentUser != null && _currentUser.ContainsKey("userRole") && _currentUser["userRole"] == "User")
            {
                if (search.IsReviewer == true)
                    search.ReviewerId = int.Parse(_authService.GetUserId());
                if (search.IsReviewed == true)
                    search.ReviewedId = int.Parse(_authService.GetUserId());
            }

            if (search.ReviewerId.HasValue)
                query = query.Where(ur => ur.ReviewerId == search.ReviewerId.Value);

            if (search.ReviewedId.HasValue)
                query = query.Where(ur => ur.ReviewedId == search.ReviewedId.Value);

            if (search.ReservationId.HasValue)
                query = query.Where(ur => ur.ReservationId == search.ReservationId.Value);

            if (search.MinRating.HasValue)
                query = query.Where(ur => ur.RatingNumber >= search.MinRating.Value);

            if (search.MaxRating.HasValue)
                query = query.Where(ur => ur.RatingNumber <= search.MaxRating.Value);

            if (search.RatingDateFrom.HasValue)
                query = query.Where(ur => ur.RatingDate >= DateOnly.FromDateTime(search.RatingDateFrom.Value));

            if (search.RatingDateTo.HasValue)
                query = query.Where(ur => ur.RatingDate <= DateOnly.FromDateTime(search.RatingDateTo.Value));

            return query;
        }
        protected override async Task BeforeInsert(UserReview entity, UserReviewInsertRequest request)
        {
            if (entity.ReviewerId == null)
                entity.ReviewerId = int.Parse(_authService.GetUserId());

            if (entity.ReviewerId == entity.ReviewedId)
                throw new UserException("You cannot review yourself.");

            if (entity.ReservationId.HasValue)
            {
                var reservation = await _context.Reservations
                    .FirstOrDefaultAsync(r => r.Id == entity.ReservationId.Value);

                if (reservation == null)
                    throw new UserException("Reservation not found.");

                var endDateTime = reservation.ReservationDate.ToDateTime(reservation.EndTime);
                if (DateTime.UtcNow < endDateTime)
                    throw new UserException("You can only leave a review after the appointment has ended.");

                var alreadyReviewed = await _context.UserReviews
                    .AnyAsync(ur => ur.ReservationId == entity.ReservationId.Value && ur.ReviewerId == entity.ReviewerId.Value && ur.ReviewedId == entity.ReviewedId.Value);
                if (alreadyReviewed)
                    throw new UserException("You have already submitted a review for this player on this reservation.");

                bool isReviewerParticipant = reservation.UserId == entity.ReviewerId.Value || 
                    await _context.PlayRequests.AnyAsync(pr => pr.Post!.ReservationId == entity.ReservationId.Value && pr.RequesterId == entity.ReviewerId.Value && pr.isAccepted == true);

                bool isReviewedParticipant = reservation.UserId == entity.ReviewedId.Value || 
                    await _context.PlayRequests.AnyAsync(pr => pr.Post!.ReservationId == entity.ReservationId.Value && pr.RequesterId == entity.ReviewedId.Value && pr.isAccepted == true);

                if (!isReviewerParticipant || !isReviewedParticipant)
                    throw new UserException("Both users must be participants in this reservation.");
            }

            await base.BeforeInsert(entity, request);
        }
        public override IQueryable<UserReview> ApplyIncludes(IQueryable<UserReview> query)
        {
            return query
                .Include(ur => ur.Reviewer)
                .Include(ur => ur.Reviewed)
                .Include(ur => ur.Reservation)
                    .ThenInclude(r => r.ChosenSport)
                .Include(ur => ur.Reservation)
                    .ThenInclude(r => r.Posts);
        }

        protected override UserReviewResponse MapToResponse(UserReview entity)
        {
            var response = base.MapToResponse(entity);
            if (entity.Reservation != null)
            {
                response.SportName = entity.Reservation.ChosenSport?.Name;
                response.SkillLevel = entity.Reservation.Posts?.FirstOrDefault()?.SkillLevel;
            }
            return response;
        }
    }
}
