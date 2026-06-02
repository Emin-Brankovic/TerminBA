using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;

namespace TerminBA.Services.Interfaces
{
    public interface ISportCenterService : IBaseCRUDService<SportCenterResponse, SportCenterSearchObject, SportCenterInsertRequest, SportCenterUpdateRequest>
    {
        public Task<AuthResponse?> Login(SportCenterLoginRequest request);
        public Task<SportCenterResponse> GetCurrentSportCenter();
        public Task<SportCenterResponse> UpdateCurrentGallery(SportCenterGalleryUpdateRequest request);
        public Task<PagedResult<SportCenterResponse>> SearchAvailableAsync(SportCenterAvailabilitySearchObject search);
        public Task<double> GetAverageRatingAsync(int sportCenterId);
    }
}

