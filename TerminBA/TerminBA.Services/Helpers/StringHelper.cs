using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Helpers
{
    public static class StringHelper
    {
        public static string GenerateRandomString(int length=14)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
            char[] result = new char[length];

            for (int i = 0; i < length; i++)
            {
                result[i] = chars[RandomNumberGenerator.GetInt32(chars.Length)];
            }

            return new string(result);
        }
    }
}
