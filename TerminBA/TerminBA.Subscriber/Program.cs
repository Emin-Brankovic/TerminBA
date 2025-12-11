using DotNetEnv;
using EasyNetQ;
using Microsoft.Extensions.Configuration;
using TerminBA.Models.Messages;
using TerminBA.Services.Service;

var builder = new ConfigurationBuilder()
              .AddEnvironmentVariables();

var configuration = builder.Build();

try
{
    Env.Load("..\\..\\..\\..\\.env");
}
catch
{
}

var from = Environment.GetEnvironmentVariable("From");

var emailService = new EmailService(configuration);

// Build RabbitMQ connection string from environment variables
var rabbitmqHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
var rabbitmqPort = Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672";
var rabbitmqUser = Environment.GetEnvironmentVariable("RABBITMQ_USER") ?? "guest";
var rabbitmqPassword = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";

var connectionString = $"host={rabbitmqHost};port={rabbitmqPort};username={rabbitmqUser};password={rabbitmqPassword}";
var bus = RabbitHutch.CreateBus(connectionString);

Console.WriteLine("Email subscriber started...");

await bus.PubSub.SubscribeAsync<EmailMessage>("email_sender", async msg =>
{
    Console.WriteLine($"Sending email to: {msg.RecipientEmail}");

    if(msg.RecipientEmail != null && msg.MessageBody != null)
    {
         await emailService.SendEmailAsync(msg.RecipientEmail, msg.MessageBody);
    }


    Console.WriteLine($"Email sent to: {msg.RecipientEmail}");
});


// Keep the application running
await Task.Delay(Timeout.Infinite);

