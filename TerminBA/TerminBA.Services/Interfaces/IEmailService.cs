using System.Threading.Tasks;

namespace TerminBA.Services.Interfaces
{
    public interface IEmailService
    {
        Task SendEmailAsync(string recipientEmail, string message, string subject = "Reservation Made");
    }
}
