using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Helpers
{
    public static class HashingHelper
    {
        public static string GenerateSalt()
        {
            int saltSize = 16;

            byte[] saltBytes = new byte[saltSize];

            using (var rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(saltBytes);
            }

            return Convert.ToBase64String(saltBytes);
        }

        public static string GenerateHash(string salt, string password)
        {
            string saltedPassword = salt + password;

            using (var sha256 = SHA256.Create())
            {
                byte[] saltedPasswordBytes = Encoding.UTF8.GetBytes(saltedPassword);
                byte[] hashBytes = sha256.ComputeHash(saltedPasswordBytes);

                return Convert.ToBase64String(hashBytes);
            }
        }
    }
}
