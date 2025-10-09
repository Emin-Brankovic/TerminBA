using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Model
{
    public class AuthResponse
    {
        public string AccessToken { get; set; } = string.Empty;
        //public string RefreshToken { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
        public int AccountId { get; set; } = default!;
    }
}
