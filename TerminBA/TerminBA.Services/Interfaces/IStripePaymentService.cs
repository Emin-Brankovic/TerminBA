using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;

namespace TerminBA.Services.Interfaces
{
    public interface IStripePaymentService
    {
        Task<PaymentIntentResponse> CreatePaymentIntentAsync(PaymentIntentRequest request);
        Task<Stripe.PaymentIntent> GetPaymentIntentAsync(string paymentIntentId);
        Task<string> ConfirmPaymentAsync(string paymentIntentId);
        Task<string> CreateRefundAsync(string paymentIntentId, decimal amount);
    }
}
