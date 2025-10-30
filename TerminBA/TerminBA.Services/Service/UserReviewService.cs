using MapsterMapper;
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
    public class UserReviewService : BaseCRUDService<UserReviewResponse, UserReview, UserReviewSearchObject, UserReviewInsertRequest, UserReviewUpdateRequest>, IUserReviewService
    {
        public UserReviewService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<UserReview> ApplyFilter(IQueryable<UserReview> query, UserReviewSearchObject search)
        {
            if (search.ReviewerId.HasValue)
                query = query.Where(ur => ur.ReviewerId == search.ReviewerId.Value);

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
    }
}
