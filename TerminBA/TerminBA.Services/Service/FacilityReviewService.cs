using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

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

            if (_currentUser["userRole"] == "User")
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
    }
}
