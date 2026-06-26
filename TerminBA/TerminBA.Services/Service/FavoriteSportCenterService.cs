using MapsterMapper;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;
using TerminBA.Models.SearchObjects;
using TerminBA.Models.Requests;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Model;
using System.Threading.Tasks;

namespace TerminBA.Services.Service
{
    public class FavoriteSportCenterService : BaseCRUDService<FavoriteSportCenterResponse, FavoriteSportCenter, FavoriteSportCenterSearchObject, FavoriteSportCenterInsertRequest, object>, IFavoriteSportCenterService
    {
        private readonly IAuthService<AccountBase> _authService;

        public FavoriteSportCenterService(TerminBaContext context, IMapper mapper, IAuthService<AccountBase> authService) : base(context, mapper)
        {
            _authService = authService;
        }

        public override async Task<FavoriteSportCenterResponse> CreateAsync(FavoriteSportCenterInsertRequest request)
        {
            request.UserId = int.Parse(_authService.GetUserId());
            return await base.CreateAsync(request);
        }

        public override IQueryable<FavoriteSportCenter> ApplyFilter(IQueryable<FavoriteSportCenter> query, FavoriteSportCenterSearchObject? search = null)
        {
            var currentUser = _authService.GetCurrentUser();
            if (currentUser.ContainsKey("userRole") && currentUser["userRole"] == "User")
            {
                var userId = int.Parse(_authService.GetUserId());
                query = query.Where(x => x.UserId == userId);
            }
            else if (search?.UserId != null)
            {
                query = query.Where(x => x.UserId == search.UserId);
            }

            if (search?.SportCenterId != null)
            {
                query = query.Where(x => x.SportCenterId == search.SportCenterId);
            }

            return query;
        }

        public override IQueryable<FavoriteSportCenter> ApplyIncludes(IQueryable<FavoriteSportCenter> query)
        {
            return query.Include(x => x.SportCenter)
                        .ThenInclude(sc => sc.Photos)
                        .Include(x => x.SportCenter)
                        .ThenInclude(sc => sc.City);
        }
    }
}
