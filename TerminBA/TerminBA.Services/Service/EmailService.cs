using System;
using System.Threading.Tasks;
using MailKit.Security;
using MimeKit.Text;
using MimeKit;
using MailKit.Net.Smtp;
using Microsoft.Extensions.Configuration;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _config;

        public EmailService(IConfiguration config)
        {
            this._config = config;
        }

        public async Task SendEmailAsync(string recipientEmail, string message, string subject = "Reservation Made")
        {
            var from = (Environment.GetEnvironmentVariable("From") ?? _config["From"])?.Trim();
            if (string.IsNullOrEmpty(from))
            {
                throw new InvalidOperationException("Email 'From' is not configured.");
            }

            var emailMessage = new MimeMessage();
            emailMessage.From.Add(MailboxAddress.Parse(from));
            emailMessage.To.Add(MailboxAddress.Parse(recipientEmail.Trim()));
            emailMessage.Subject = subject;
            emailMessage.Body = new TextPart(TextFormat.Html) { Text = message };

            var smtpServer = (Environment.GetEnvironmentVariable("SmtpServer") ?? _config["SmtpServer"])?.Trim()
                ?? throw new InvalidOperationException("SmtpServer is not configured.");
            var username = (Environment.GetEnvironmentVariable("Username") ?? _config["Username"])?.Trim();
            var password = (Environment.GetEnvironmentVariable("AppPassword") ?? _config["AppPassword"])?.Trim();
            var portStr = (Environment.GetEnvironmentVariable("SmtpPort") ?? _config["SmtpPort"])?.Trim();
            var port = !string.IsNullOrEmpty(portStr) && int.TryParse(portStr, out int p) ? p : 587;

            using var smtp = new SmtpClient();
            await smtp.ConnectAsync(smtpServer, port, SecureSocketOptions.StartTls);
            if (!string.IsNullOrEmpty(username) && !string.IsNullOrEmpty(password))
            {
                await smtp.AuthenticateAsync(username, password);
            }
            await smtp.SendAsync(emailMessage);
            await smtp.DisconnectAsync(true);
        }
    }
}
