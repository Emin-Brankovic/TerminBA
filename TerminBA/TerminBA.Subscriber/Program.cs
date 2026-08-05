using DotNetEnv;
using EasyNetQ;
using Microsoft.Extensions.Configuration;
using TerminBA.Models.Messages;
using TerminBA.Services.Service;

try
{
    Env.Load("..\\..\\..\\..\\.env");
}
catch (Exception ex)
{
    Console.WriteLine($"Could not load .env file: {ex.Message}");
}

var builder = new ConfigurationBuilder()
              .AddEnvironmentVariables();

var configuration = builder.Build();

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
    int maxRetries = 4;
    int delayMs = 1000;
    
    for (int attempt = 1; attempt <= maxRetries + 1; attempt++)
    {
        try
        {
            Console.WriteLine($"[Attempt {attempt}] Sending email to: {msg.RecipientEmail}");

            if (msg.RecipientEmail != null && msg.MessageBody != null)
            {
                 await emailService.SendEmailAsync(msg.RecipientEmail, msg.MessageBody);
            }

            Console.WriteLine($"Email sent to: {msg.RecipientEmail}");
            break; // Success, exit retry loop
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error processing email message on attempt {attempt}: {ex.Message}");
            
            if (attempt > maxRetries)
            {
                Console.WriteLine($"Failed to process message for {msg.RecipientEmail} after {maxRetries} retries. Error: {ex}");
                throw; // Rethrow so EasyNetQ can move it to the error queue
            }
            
            await Task.Delay(delayMs);
            delayMs *= 2; // Exponential backoff: 1s, 2s, 4s, 8s
        }
    }
});

// Keep the application running
await Task.Delay(Timeout.Infinite);

