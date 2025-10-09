using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Services.Database;

namespace TerminBA.Services.Interfaces
{
    public interface IAuthService <TEntity> where TEntity : AccountBase
    {
        public Task<AuthResponse?> Login(BaseLoginRequest request);
    }
}
