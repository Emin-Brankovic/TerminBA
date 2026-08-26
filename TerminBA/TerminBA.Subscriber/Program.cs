using DotNetEnv;
using EasyNetQ;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
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

using var loggerFactory = LoggerFactory.Create(loggingBuilder =>
{
    loggingBuilder
        .AddConfiguration(configuration.GetSection("Logging"))
        .AddConsole();
});

ILogger logger = loggerFactory.CreateLogger<Program>();

var from = Environment.GetEnvironmentVariable("From");

var emailService = new EmailService(configuration);

// Build RabbitMQ connection string from environment variables
var rabbitmqHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
var rabbitmqPort = Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672";
var rabbitmqUser = Environment.GetEnvironmentVariable("RABBITMQ_USER") ?? "guest";
var rabbitmqPassword = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";

var connectionString = $"host={rabbitmqHost};port={rabbitmqPort};username={rabbitmqUser};password={rabbitmqPassword}";
var bus = RabbitHutch.CreateBus(connectionString);

logger.LogInformation("Email subscriber started...");

await bus.PubSub.SubscribeAsync<EmailMessage>("email_sender", async msg =>
{
    int maxRetries = 4;
    int delayMs = 1000;
    
    for (int attempt = 1; attempt <= maxRetries + 1; attempt++)
    {
        try
        {
            logger.LogInformation("[Attempt {Attempt}] Sending email to: {RecipientEmail}", attempt, msg.RecipientEmail);

            if (msg.RecipientEmail != null && msg.MessageBody != null)
            {
                 await emailService.SendEmailAsync(msg.RecipientEmail, msg.MessageBody);
            }

            logger.LogInformation("Email sent to: {RecipientEmail}", msg.RecipientEmail);
            break;
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Error processing email message on attempt {Attempt}", attempt);
            
            if (attempt > maxRetries)
            {
                logger.LogError(ex, "Failed to process message for {RecipientEmail} after {MaxRetries} retries.", msg.RecipientEmail, maxRetries);
                throw;
            }
            
            await Task.Delay(delayMs);
            delayMs *= 2;
        }
    }
});

await Task.Delay(Timeout.Infinite);

