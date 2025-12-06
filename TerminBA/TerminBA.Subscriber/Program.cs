using DotNetEnv;
using EasyNetQ;
using Microsoft.Extensions.Configuration;
using TerminBA.Models.Messages;
using TerminBA.Services.Service;

var builder = new ConfigurationBuilder()
              .AddEnvironmentVariables();

var configuration = builder.Build();

//ne moze biti apsolutna putanja do env, mora biti dinamicka
Env.Load("C:\\Users\\Emin Brankovic\\Desktop\\TerminBA\\TerminBA\\TerminBA.Subscriber\\.env");

var from = Environment.GetEnvironmentVariable("From");
Console.WriteLine(from);

var emailService = new EmailService(configuration);
var bus = RabbitHutch.CreateBus("host=localhost");

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


Console.WriteLine("Press any key to exit");
Console.ReadKey();

