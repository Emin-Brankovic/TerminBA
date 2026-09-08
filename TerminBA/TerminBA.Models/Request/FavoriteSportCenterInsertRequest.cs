using System;

namespace TerminBA.Models.Request
{
    public class FavoriteSportCenterInsertRequest
    {
        public int UserId { get; set; }
        public int SportCenterId { get; set; }
    }
}
