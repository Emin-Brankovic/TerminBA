using EasyNetQ;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Exceptions;
using TerminBA.Models.Messages;
using TerminBA.Services.Database;

namespace TerminBA.Services.Helpers
{
    public static class EmailPublisherHelper
    {
        public static async Task PublishReservationCreatedEmailAsync(IBus bus, TerminBaContext context, int reservationId)
        {
            var reservation = await context.Reservations
                .Include(r => r.User)
                .Include(r => r.Facility)
                    .ThenInclude(f => f.SportCenter)
                .FirstOrDefaultAsync(r => r.Id == reservationId);

            if (reservation == null)
                throw new UserException("Reservation not found");

            if (reservation.User == null)
                throw new UserException("User not found");

            var emailMessage = new EmailMessage
            {
                RecipientEmail = reservation.User.Email ?? string.Empty,
                MessageBody = $@"
                    <h2>Your reservation has been successfully created. Thank you!</h2>
                    <p><b>Date:</b> {reservation.ReservationDate:dd.MM.yyyy}</p>
                    <p><b>Time:</b> {reservation.StartTime:HH:mm} - {reservation.EndTime:HH:mm}</p>
                    <p><b>Sport Center:</b> {reservation?.Facility?.SportCenter?.Username ?? "Unknown"}</p>
                    <p><b>Facility:</b> {reservation.Facility?.Name ?? "Unknown"}</p>
                    <p><b>Price:</b> {reservation.Price:F2} BAM</p>
                "
            };

            await bus.PubSub.PublishAsync(emailMessage);
        }

        public static async Task PublishPasswordResetEmailAsync(IBus bus, string recipientEmail, string resetCode)
        {
            var emailMessage = new EmailMessage
            {
                RecipientEmail = recipientEmail,
                Subject = "TerminBA - Password Reset Code",
                MessageBody = $@"
                    <div style=""font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 24px; border: 1px solid #e0e0e0; border-radius: 8px; background-color: #ffffff;"">
                        <h2 style=""color: #00C875; text-align: center; margin-top: 0;"">TerminBA Password Reset</h2>
                        <p style=""font-size: 15px; color: #333;"">Hello,</p>
                        <p style=""font-size: 15px; color: #333;"">You recently requested to reset your password. Use the verification code below to set a new password:</p>
                        <div style=""text-align: center; margin: 28px 0;"">
                            <span style=""display: inline-block; font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #111; background-color: #f3fdf7; padding: 14px 28px; border-radius: 8px; border: 2px dashed #00C875;"">
                                {resetCode}
                            </span>
                        </div>
                        <p style=""color: #666; font-size: 14px;"">This code is time-limited and valid for <strong>15 minutes</strong>.</p>
                        <p style=""color: #888; font-size: 13px;"">If you did not request a password reset, you can safely ignore this email. Your account remains secure.</p>
                        <hr style=""border: none; border-top: 1px solid #eee; margin: 24px 0 16px 0;"" />
                        <p style=""color: #aaa; font-size: 12px; text-align: center; margin: 0;"">&copy; TerminBA. All rights reserved.</p>
                    </div>"
            };

            await bus.PubSub.PublishAsync(emailMessage);
        }
    }
}
