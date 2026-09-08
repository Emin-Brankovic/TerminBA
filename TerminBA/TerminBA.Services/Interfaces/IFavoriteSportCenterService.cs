using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;

namespace TerminBA.Services.Interfaces
{
    public interface IFavoriteSportCenterService : IBaseCRUDService<FavoriteSportCenterResponse, FavoriteSportCenterSearchObject, FavoriteSportCenterInsertRequest, object>
    {
    }
}
