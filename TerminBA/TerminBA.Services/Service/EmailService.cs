using MailKit.Security;
using MimeKit.Text;
using MimeKit;
using MailKit.Net.Smtp;
using Microsoft.Extensions.Configuration;

namespace TerminBA.Services.Service
{
    public class EmailService
    {
        private readonly IConfiguration _config;

        public EmailService(IConfiguration config)
        {
            this._config = config;
        }


        public async Task SendEmailAsync(string recipientEmail, string message)
        {
            var from = Environment.GetEnvironmentVariable("From");

            //var from = _config["EmailSettings:SenderEmail"];

            var emailMessage = new MimeMessage();
            emailMessage.From.Add(MailboxAddress.Parse(from));
            emailMessage.To.Add(MailboxAddress.Parse(recipientEmail));
            emailMessage.Subject = "Reservation Made";
            emailMessage.Body = new TextPart(TextFormat.Html) { Text = message };

            var smtpServer = Environment.GetEnvironmentVariable("SmtpServer");
            var username = Environment.GetEnvironmentVariable("Username");
            var password = Environment.GetEnvironmentVariable("AppPassword");
            var port = int.Parse(Environment.GetEnvironmentVariable("SmtpPort"));


            //var   smtpServer = config["EmailSettings:SmtpServer"];
            //var  username = config["EmailSettings:Username"];
            //var password = config["EmailSettings:AppPassword"];
            //var port = config["EmailSettings:SmtpPort"];

            using var smtp = new SmtpClient();
            await smtp.ConnectAsync(smtpServer, port, SecureSocketOptions.StartTls);
            await smtp.AuthenticateAsync(username, password);
            await smtp.SendAsync(emailMessage);
            await smtp.DisconnectAsync(true);

        }
    }
}
