using Microsoft.Extensions.Logging;
using Stripe;
using TerminBA.Models.Model;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class StripePaymentService : IStripePaymentService
    {

        public StripePaymentService()
        {

            var secretKey = Environment.GetEnvironmentVariable("StripeSecretKey")
                ?? throw new InvalidOperationException("StripeSecretKey environment variable is not set.");

            StripeConfiguration.ApiKey = secretKey;
        }

        public async Task<PaymentIntentResponse> CreatePaymentIntentAsync(PaymentIntentRequest request)
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = request.Amount,
                Currency = request.Currency.ToLowerInvariant(),
                PaymentMethodTypes = new List<string> { "card" },
                Metadata = new Dictionary<string, string>
                {
                    { "facilityId", request.FacilityId?.ToString() ?? string.Empty },
                    { "userId",     request.UserId?.ToString()     ?? string.Empty },
                    { "source",     "TerminBA-Mobile" },
                },
            };

            var service = new PaymentIntentService();

            try
            {
                var paymentIntent = await service.CreateAsync(options);

                return new PaymentIntentResponse
                {
                    ClientSecret    = paymentIntent.ClientSecret,
                    PaymentIntentId = paymentIntent.Id,
                    Status          = paymentIntent.Status,
                };
            }
            catch (StripeException ex)
            {
                throw new Exception($"Payment processing failed: {ex.StripeError?.Message ?? "unknown error"}");
            }
        }
    }
}
