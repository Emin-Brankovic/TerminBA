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
    public class FacilityReviewService : BaseCRUDService<FacilityReviewResponse, FacilityReview, FacilityReviewSearchObject, FacilityReviewInsertRequest, FacilityReviewUpdateRequest>, IFacilityReviewService
    {
        public FacilityReviewService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<FacilityReview> ApplyFilter(IQueryable<FacilityReview> query, FacilityReviewSearchObject search)
        {
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

            return query;
        }
    }
}
