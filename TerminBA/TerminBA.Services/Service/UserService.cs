using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class UserService : BaseCRUDService<UserResponse, User, UserSearchObject, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        public UserService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
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

        public async Task<UserResponse?> Login(UserLoginRequest request)
        {
           var entity=await _context.Users.FirstOrDefaultAsync(u=>u.Username == request.Username);

            if (entity == null)
                return null;
            var hash=GenerateHash(entity.PasswordSalt, request.Password);

            if(hash != entity.PasswordHash) 
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(User entity, UserInsertRequest request)
        {
            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);
        }

    }
}


