using System;

namespace TerminBA.Models.SearchObjects
{
    public class FavoriteSportCenterSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? SportCenterId { get; set; }
    }
}
