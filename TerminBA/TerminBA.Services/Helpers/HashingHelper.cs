using System.Security.Cryptography;
using System.Text;


namespace TerminBA.Services.Helpers
{
    public static class HashingHelper
    {
        private const int SaltSize = 32;
        private const int HashSize = 64;
        private const int Iterations = 300_000;

        public static string GenerateSalt()
        {
            byte[] saltBytes = new byte[SaltSize];
            RandomNumberGenerator.Fill(saltBytes);
            return Convert.ToBase64String(saltBytes);
        }

        public static string GenerateHash(string salt, string password)
        {
            byte[] saltBytes = Convert.FromBase64String(salt);
            byte[] passwordBytes = Encoding.UTF8.GetBytes(password);

            byte[] hashBytes = Rfc2898DeriveBytes.Pbkdf2(
                passwordBytes,
                saltBytes,
                Iterations,
                HashAlgorithmName.SHA512,
                HashSize);

            return Convert.ToBase64String(hashBytes);
        }
    }
}
