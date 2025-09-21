using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class UserResponse
    {
        public int Id { get; set; }

        public string? FirstName { get; set; }

        public string? LastName { get; set; }

        public int Age { get; set; }

        public string? Username { get; set; }

        public string? Email { get; set; }

        public string? PhoneNumber { get; set; }

        public string? InstagramAccount { get; set; }

        public DateOnly BirthDate { get; set; }

        public int CityId { get; set; }
        public CityResponse? City { get; set; }

        public int RoleId { get; set; }
        public RoleResponse? Role { get; set; }

        public bool IsActive { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        public ICollection<ReservationResponse> Reservations { get; set; } = new List<ReservationResponse>();

        public ICollection<UserReviewResponse> UserReviewsGiven { get; set; } = new List<UserReviewResponse>();
        public ICollection<UserReviewResponse> ReviewsReceived { get; set; } = new List<UserReviewResponse>();
        public ICollection<FacilityReviewResponse> FacilityReviewsGiven { get; set; } = new List<FacilityReviewResponse>();
    }
}



