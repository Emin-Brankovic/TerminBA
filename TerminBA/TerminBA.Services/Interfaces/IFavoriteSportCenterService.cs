using TerminBA.Models.Model;
using TerminBA.Models.Requests;
using TerminBA.Models.SearchObjects;

namespace TerminBA.Services.Interfaces
{
    public interface IFavoriteSportCenterService : IBaseCRUDService<FavoriteSportCenterResponse, FavoriteSportCenterSearchObject, FavoriteSportCenterInsertRequest, object>
    {
    }
}
