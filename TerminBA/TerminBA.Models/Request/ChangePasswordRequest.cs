using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Models.Request
{
    public class ChangePasswordRequest
    {
        [Required(ErrorMessage = "Current password is required")]
        public string CurrentPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "Confirm current password is required")]
        [Compare("CurrentPassword", ErrorMessage = "Current passwords do not match")]
        public string ConfirmCurrentPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "New password is required")]
        public string NewPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "Confirm new password is required")]
        [Compare("NewPassword", ErrorMessage = "New passwords do not match")]
        public string ConfirmNewPassword { get; set; } = string.Empty;
    }
}
