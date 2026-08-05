using EasyNetQ;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Execptions;
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
    }
}
