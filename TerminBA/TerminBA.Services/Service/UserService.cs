using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Exceptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;
using TerminBA.Services.PlayRequestStateMachine;
using TerminBA.Services.PostStateMachine;
using TerminBA.Services.ReservationStateMachine;

namespace TerminBA.Services.Service
{
    public class UserService : BaseCRUDService<UserResponse, User, UserSearchObject, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        private readonly IAuthService<User> _authService;

        public UserService(TerminBaContext context, IMapper mapper,IAuthService<User> authService) : base(context, mapper)
        {
            this._authService = authService;
        }

        public override IQueryable<User> ApplyFilter(IQueryable<User> query, UserSearchObject search)
        {
            query=query.Where(u=>u.RoleId==1);

            if (!string.IsNullOrEmpty(search.FullName))
                query = query.Where(u => u.FirstName!.ToLower().Contains(search.FullName.ToLower())
                || u.LastName!.ToLower().Contains(search.FullName.ToLower()) || u.Username!.ToLower().Contains(search.FullName.ToLower()));

            if (!string.IsNullOrEmpty(search.Username))
                query = query.Where(u => u.Username!.ToLower().Contains(search.Username.ToLower()));

            if (!string.IsNullOrEmpty(search.Email))
                query = query.Where(u => u.Email!.ToLower().Contains(search.Email.ToLower()));

            if (search.CityId.HasValue)
                query = query.Where(u => u.CityId == search.CityId.Value);

            return query;
        }

        public async Task<AuthResponse?> Login(UserLoginRequest request)
        {
           var response=await _authService.Login(request);

            return response;
        }

        protected override async Task BeforeInsert(User entity, UserInsertRequest request)
        {
            await UserExists(entity.Username!, entity.Email!);


            if (string.IsNullOrEmpty(request.Password))
                throw new UserException("Password is required.");

            var hasNumber = new System.Text.RegularExpressions.Regex(@"[0-9]+");
            var hasUpperChar = new System.Text.RegularExpressions.Regex(@"[A-Z]+");
            var hasLowerChar = new System.Text.RegularExpressions.Regex(@"[a-z]+");
            var hasMinimum8Chars = new System.Text.RegularExpressions.Regex(@".{8,}");
            var hasSpecialChar = new System.Text.RegularExpressions.Regex(@"[!@#$%^&*()_+=\[{\]};:<>|./?,-]");

            if (!hasMinimum8Chars.IsMatch(request.Password) ||
                !hasNumber.IsMatch(request.Password) ||
                !hasUpperChar.IsMatch(request.Password) ||
                !hasLowerChar.IsMatch(request.Password) ||
                !hasSpecialChar.IsMatch(request.Password))
            {
                throw new UserException("Password does not meet the security policy.");
            }

            entity.PasswordSalt = HashingHelper.GenerateSalt();
            entity.PasswordHash = HashingHelper.GenerateHash(entity.PasswordSalt, request.Password!);
            entity.RoleId = 1;
        }

        protected async override Task BeforeUpdate(User entity, UserUpdateRequest request)
        {
            var currentUser = _authService.GetCurrentUser();
            var currentUserIdStr = currentUser["userId"];
            var currentUserRole = currentUser.ContainsKey("userRole") ? currentUser["userRole"] : null;

            if (currentUserRole != "Administrator")
            {
                if (!int.TryParse(currentUserIdStr, out int currentUserId) || currentUserId != entity.Id)
                {
                    throw new UserException("You are not authorized to update this profile.");
                }
            }

            if (entity.Email!.ToLower()!=request.Email!.ToLower())
            {
                if(await _context.Users.AnyAsync(u=>u.Email!.ToLower() == request.Email.ToLower()))
                 throw new UserException("Email is already taken");
            }

            if (entity.Username!.ToLower() != request.Username!.ToLower())
            {
                if (await _context.Users.AnyAsync(u => u.Username!.ToLower() == request.Username.ToLower()))
                    throw new UserException("Username is already taken");
            }

            entity.UpdatedAt = DateTime.UtcNow;
        }

        protected override async Task BeforeDelete(User entity)
        {
            var currentUser = _authService.GetCurrentUser();
            var currentUserIdStr = currentUser["userId"];
            var currentUserRole = currentUser.ContainsKey("userRole") ? currentUser["userRole"] : null;

            if (currentUserRole != "Administrator")
            {
                if (!int.TryParse(currentUserIdStr, out int currentUserId) || currentUserId != entity.Id)
                {
                    throw new UserException("You are not authorized to delete this profile.");
                }
            }
            else
            {
                var activeReservationStates = new[] { nameof(ActiveReservationState), nameof(PendingReservationState) };
                if (await _context.Reservations.AnyAsync(r => r.UserId == entity.Id && activeReservationStates.Contains(r.Status)))
                    throw new UserException("Cannot delete user because they have active reservations.");

                if (await _context.PlayRequests.AnyAsync(pr => 
                    pr.RequesterId == entity.Id && 
                    (pr.PlayRequestState == nameof(PendingPlayRequestState) || 
                    (pr.PlayRequestState == nameof(AcceptedPlayRequestState) && pr.Post!.Reservation!.Status != nameof(CompletedReservationState)))))
                {
                    throw new UserException("Cannot delete user because they have active play requests.");
                }
                    
                var activePostStates = new[] { nameof(PlayerSearchPostState), nameof(PlayerFoundPostState), nameof(DraftPostState) };
                if (await _context.Posts.AnyAsync(p => p.Reservation!.UserId == entity.Id && activePostStates.Contains(p.PostState)))
                    throw new UserException("Cannot delete user because they have active posts.");
            }

            // Cleanup dependent records
            // 1. PlayRequests: Delete
            var playRequests = await _context.PlayRequests.Where(pr => pr.RequesterId == entity.Id).ToListAsync();
            if (playRequests.Any())
                _context.RemoveRange(playRequests);

            var respondedRequests = await _context.PlayRequests.Where(pr => pr.RespondedById == entity.Id).ToListAsync();
            foreach (var pr in respondedRequests) pr.RespondedById = null;

            var canceledRequests = await _context.PlayRequests.Where(pr => pr.CanceledById == entity.Id).ToListAsync();
            foreach (var pr in canceledRequests) pr.CanceledById = null;

            // 2. Reservations: Persist (nullify UserId)
            var reservations = await _context.Reservations.Where(r => r.UserId == entity.Id).ToListAsync();
            foreach (var r in reservations)
            {
                r.UserId = null;
            }

            // 3. Payments: Persist (nullify UserId)
            var payments = await _context.Payments.Where(p => p.UserId == entity.Id).ToListAsync();
            foreach(var p in payments)
            {
                p.UserId = null;
            }

            // 4. RecommendationEvents: Delete
            var recEvents = await _context.RecommendationEvents.Where(re => re.UserId == entity.Id).ToListAsync();
            if (recEvents.Any())
                _context.RemoveRange(recEvents);

            // 5. UserReviews (Received): Delete
            var recievedReviews = await _context.UserReviews.Where(ur => ur.ReviewedId == entity.Id).ToListAsync();
            if (recievedReviews.Any())
                _context.RemoveRange(recievedReviews);

            // 6. UserReviews (Given): Persist (nullify ReviewerId)
            var givenReviews = await _context.UserReviews.Where(ur => ur.ReviewerId == entity.Id).ToListAsync();
            foreach(var gr in givenReviews)
            {
                gr.ReviewerId = null;
            }

            // 7. FacilityReviews (Given): Persist (nullify UserId)
            var facilityReviews = await _context.FacilityReviews.Where(fr => fr.UserId == entity.Id).ToListAsync();
            foreach(var fr in facilityReviews)
            {
                fr.UserId = null;
            }

            // 8. FavoriteSportCenters: Delete
            var favorites = await _context.FavoriteSportCenters.Where(fsc => fsc.UserId == entity.Id).ToListAsync();
            if (favorites.Any())
                _context.RemoveRange(favorites);

            // 9. Notifications: Delete
            var cancelNotifications = await _context.CancelationNotifications.Where(cn => cn.PostOwnerId == entity.Id).ToListAsync();
            if (cancelNotifications.Any())
                _context.RemoveRange(cancelNotifications);

            var updateNotifications = await _context.UpdateNotifications.Where(un => un.PostOwnerId == entity.Id).ToListAsync();
            if (updateNotifications.Any())
                _context.RemoveRange(updateNotifications);
        }

        public override IQueryable<User> ApplyIncludes(IQueryable<User> query)
        {
            return query
                .Include(u => u.City)
                .Include(u => u.Role);
        }

        private async Task UserExists(string username,string email)
        {
            if (await _context.Users.AnyAsync(u => u.Email!.ToLower() == email.ToLower()))
                throw new UserException("Email is already taken");

            if (await _context.Users.AnyAsync(u => u.Username!.ToLower() == username.ToLower()))
                throw new UserException("Username is already taken");

        }

        public async Task<int> GetPlayedMatches(int id)
        {
            var count = await _context.PlayRequests
                .Where(pr => pr.RequesterId == id && pr.Post.PostState == nameof(FinishedPostState) && pr.PlayRequestState == nameof(AcceptedPlayRequestState))
                .CountAsync();
            return count;
        }

        public async Task<UserResponse> GetProfile()
        {
            var userId = int.Parse(_authService.GetUserId());
            return await base.GetByIdAsync(userId);
        }

        public async Task<int> GetMyPlayedMatches()
        {
            var userId = int.Parse(_authService.GetUserId());
            return await GetPlayedMatches(userId);
        }

        public async Task Logout()
        {
            await _authService.Logout();
        }

        public async Task ChangePassword(ChangePasswordRequest request)
        {
            await _authService.ChangePassword(request);
        }

    }
}

