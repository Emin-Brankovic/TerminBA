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
using TerminBA.Services.Helpers;
using TerminBA.Models.Execptions;
using Microsoft.AspNetCore.Http;

namespace TerminBA.Services.Service
{
    //later on implement refresh tokens
    public class AuthService<TEntity> : IAuthService<TEntity> where TEntity : AccountBase
    {
        private readonly TerminBaContext _context;
        private readonly IConfiguration _config;
        private readonly IHttpContextAccessor _httpContextAccessor;


        public AuthService(TerminBaContext context, IConfiguration config, IHttpContextAccessor httpContextAccessor)
        {
            this._context = context;
            this._config = config;
            _httpContextAccessor = httpContextAccessor;
        }
        public async Task<AuthResponse?> Login(BaseLoginRequest request) 
        {
            var entity = await _context.Set<TEntity>()
                .Include(x=>x.Role)
                .FirstOrDefaultAsync(x=> request.Username == x.Username && request.RoleId==x.RoleId);

            if (entity == null)
                throw new UserException("Invalid credentials!");

            var hash = HashingHelper.GenerateHash(entity.PasswordSalt, request.Password!);

            if (hash != entity.PasswordHash)
                throw new UserException("Invalid credentials!");

            var token = CreatToken(entity);

            return token;
        }

        public AuthResponse CreatToken(AccountBase account)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var secretKey = Environment.GetEnvironmentVariable("JWTSecretKey");
            
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey ?? string.Empty));
            var creds = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256Signature);

            var tokenExperation = DateTime.UtcNow.AddDays(7);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject=new ClaimsIdentity(new List<Claim>
                {
                    new Claim(ClaimTypes.Name, account.Username!),
                    new Claim(ClaimTypes.NameIdentifier, account.Id.ToString()),
                    new Claim(ClaimTypes.Role, account.Role!.Name!)
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

        public string GetUserId()
        {
            var user = _httpContextAccessor.HttpContext?.User;
            return user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        }

        public Dictionary<string, string> GetCurrentUser()
        {
            var user = _httpContextAccessor.HttpContext?.User;
            var userId= user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var userRole= user?.FindFirst(ClaimTypes.Role)?.Value;
            var username= user?.FindFirst(ClaimTypes.Name)?.Value;

            Dictionary<string, string> currentUser = new Dictionary<string, string>
            {
                {nameof(userId), userId!},
                {nameof(userRole), userRole!},
                {nameof(username), username!}

            };


            return currentUser;
        }

        public async Task ChangePassword(ChangePasswordRequest request)
        {
            if (request.CurrentPassword != request.ConfirmCurrentPassword)
                throw new UserException("Current passwords do not match.");
            
            if (request.NewPassword != request.ConfirmNewPassword)
                throw new UserException("New passwords do not match.");

            if (request.NewPassword == request.CurrentPassword)
                throw new UserException("New password cannot be the same as the current password.");

            // Policy: min 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special character
            var hasNumber = new System.Text.RegularExpressions.Regex(@"[0-9]+");
            var hasUpperChar = new System.Text.RegularExpressions.Regex(@"[A-Z]+");
            var hasLowerChar = new System.Text.RegularExpressions.Regex(@"[a-z]+");
            var hasMinimum8Chars = new System.Text.RegularExpressions.Regex(@".{8,}");
            var hasSpecialChar = new System.Text.RegularExpressions.Regex(@"[!@#$%^&*()_+=\[{\]};:<>|./?,-]");

            if (!hasMinimum8Chars.IsMatch(request.NewPassword) ||
                !hasNumber.IsMatch(request.NewPassword) ||
                !hasUpperChar.IsMatch(request.NewPassword) ||
                !hasLowerChar.IsMatch(request.NewPassword) ||
                !hasSpecialChar.IsMatch(request.NewPassword))
            {
                throw new UserException("Password does not meet the security policy.");
            }

            var userIdString = GetUserId();
            if (string.IsNullOrEmpty(userIdString) || !int.TryParse(userIdString, out int userId))
                throw new UserException("User is not authenticated.");

            var entity = await _context.Set<TEntity>().FirstOrDefaultAsync(x => x.Id == userId);
            if (entity == null)
                throw new UserException("User not found.");

            var currentHash = HashingHelper.GenerateHash(entity.PasswordSalt, request.CurrentPassword);
            if (currentHash != entity.PasswordHash)
                throw new UserException("Current password is incorrect.");

            entity.PasswordSalt = HashingHelper.GenerateSalt();
            entity.PasswordHash = HashingHelper.GenerateHash(entity.PasswordSalt, request.NewPassword);

            _context.Set<TEntity>().Update(entity);
            await _context.SaveChangesAsync();
        }
    }
}
