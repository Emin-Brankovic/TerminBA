using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;

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
            if (!string.IsNullOrEmpty(search.FirstName))
                query = query.Where(u => u.FirstName.ToLower().Contains(search.FirstName.ToLower()));

            if (!string.IsNullOrEmpty(search.LastName))
                query = query.Where(u => u.LastName.ToLower().Contains(search.LastName.ToLower()));

            if (!string.IsNullOrEmpty(search.Username))
                query = query.Where(u => u.Username.ToLower().Contains(search.Username.ToLower()));

            if (!string.IsNullOrEmpty(search.Email))
                query = query.Where(u => u.Email.ToLower().Contains(search.Email.ToLower()));

            if (search.CityId.HasValue)
                query = query.Where(u => u.CityId == search.CityId.Value);

            if (search.IsActive.HasValue)
                query = query.Where(u => u.IsActive == search.IsActive.Value);

            return query;
        }

        public async Task<AuthResponse?> Login(UserLoginRequest request)
        {
           var response=await _authService.Login(request);

            return response;
        }

        protected override async Task BeforeInsert(User entity, UserInsertRequest request)
        {
            if (await UserExists(entity.Username!))
                throw new UserException("Username is already taken");


            entity.PasswordSalt = HashingHelper.GenerateSalt();
            entity.PasswordHash = HashingHelper.GenerateHash(entity.PasswordSalt, request.Password);
        }

        private async Task<bool> UserExists(string username)
        {
            return await _context.Users.AnyAsync(user => user.Username.ToLower() == username.ToLower());

        }

    }
}





