using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Net.Sockets;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Request;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;
using TerminBA.Models.Model;
using Microsoft.Extensions.Configuration;
using System.Security.Claims;
using Microsoft.Identity.Client;

namespace TerminBA.Services.Service
{
    //later on implement refresh tokens
    public class AuthService<TEntity> : IAuthService<TEntity> where TEntity : AccountBase
    {
        private readonly TerminBaContext _context;
        private readonly IConfiguration _config;

        public AuthService(TerminBaContext context, IConfiguration config)
        {
            this._context = context;
            this._config = config;
        }
        public async Task<AuthResponse?> Login(BaseLoginRequest request)
        {
            var entity = await _context.Set<TEntity>()
                .Include(x=>x.Role)
                .FirstOrDefaultAsync(x=> request.Username == x.Username);

            if (entity == null)
                return null;
            var hash = GenerateHash(entity.PasswordSalt, request.Password);

            if (hash != entity.PasswordHash)
                return null;

            var token = CreatToken(entity);

            return token;
        }

        private static string GenerateHash(string salt, string password)
        {
            string saltedPassword = salt + password;

            using (var sha256 = SHA256.Create())
            {
                byte[] saltedPasswordBytes = Encoding.UTF8.GetBytes(saltedPassword);
                byte[] hashBytes = sha256.ComputeHash(saltedPasswordBytes);

                return Convert.ToBase64String(hashBytes);
            }
        }

        public AuthResponse CreatToken(AccountBase account)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var secretKey = _config["JWTSecretKey"];
            
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey ?? string.Empty));
            var creds = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256Signature);

            var tokenExperation = DateTime.UtcNow.AddDays(7);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject=new ClaimsIdentity(new List<Claim>
                {
                    new Claim(ClaimTypes.Name, account.Username),
                    new Claim(ClaimTypes.NameIdentifier, account.Id.ToString()),
                    new Claim(ClaimTypes.Role, account.Role.RoleName)
                }),

                Expires=tokenExperation,
                SigningCredentials = creds,
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            var tokenString = tokenHandler.WriteToken(token);

            var authResponse = new AuthResponse
            {
                AccessToken = tokenString,
                AccountId = account.Id,
                ExpiresAt = tokenExperation,
            };

            return authResponse;
        }
    }
}
