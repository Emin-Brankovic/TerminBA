using System;

namespace TerminBA.Models.Model
{
    public class FavoriteSportCenterResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public UserResponse? User { get; set; }
        public int SportCenterId { get; set; }
        public SportCenterResponse? SportCenter { get; set; }
        public DateTime CreatedAt { get; set; }
        
    }
}
