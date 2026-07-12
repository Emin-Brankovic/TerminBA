using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;

namespace TerminBA.Services.Interfaces
{
    public interface IUserService : IBaseCRUDService<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        public Task<AuthResponse?> Login(UserLoginRequest request);
        public Task<int> GetPlayedMatches(int id);
        public Task<UserResponse> GetProfile();
        public Task<int> GetMyPlayedMatches();
    }
}
