using System;

namespace TerminBA.Models.Requests
{
    public class FavoriteSportCenterInsertRequest
    {
        public int UserId { get; set; }
        public int SportCenterId { get; set; }
    }
}
