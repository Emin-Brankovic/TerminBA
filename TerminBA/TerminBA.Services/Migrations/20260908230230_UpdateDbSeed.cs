using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdateDbSeed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "FavoriteSportCenters",
                columns: new[] { "Id", "CreatedAt", "SportCenterId", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 1, 1, 12, 0, 0, 0, DateTimeKind.Utc), 1, 2 },
                    { 2, new DateTime(2026, 1, 2, 12, 0, 0, 0, DateTimeKind.Utc), 4, 2 },
                    { 3, new DateTime(2026, 1, 3, 12, 0, 0, 0, DateTimeKind.Utc), 2, 3 },
                    { 4, new DateTime(2026, 1, 4, 12, 0, 0, 0, DateTimeKind.Utc), 3, 4 }
                });

            migrationBuilder.UpdateData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "CanceledAt", "Reason" },
                values: new object[] { new DateTime(2026, 1, 17, 18, 0, 0, 0, DateTimeKind.Utc), "Can't come, sorry" });

            migrationBuilder.UpdateData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 11,
                columns: new[] { "CanceledAt", "Reason" },
                values: new object[] { new DateTime(2026, 4, 7, 20, 0, 0, 0, DateTimeKind.Utc), "Can't come, sorry" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 1,
                column: "CompletedAt",
                value: new DateTime(2026, 1, 20, 18, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 2,
                column: "CompletedAt",
                value: new DateTime(2026, 2, 25, 19, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 3,
                column: "CompletedAt",
                value: new DateTime(2026, 3, 15, 10, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 4,
                column: "CompletedAt",
                value: new DateTime(2026, 4, 10, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 5,
                column: "CompletedAt",
                value: new DateTime(2026, 5, 5, 16, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 6,
                column: "CompletedAt",
                value: new DateTime(2026, 6, 15, 18, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 7,
                column: "CompletedAt",
                value: new DateTime(2026, 7, 20, 17, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 8,
                column: "CompletedAt",
                value: new DateTime(2026, 8, 10, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 9,
                column: "CompletedAt",
                value: new DateTime(2026, 1, 20, 15, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 10,
                column: "CompletedAt",
                value: new DateTime(2026, 2, 25, 18, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 11,
                column: "CompletedAt",
                value: new DateTime(2026, 3, 15, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 12,
                column: "CompletedAt",
                value: new DateTime(2026, 4, 10, 19, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 13,
                column: "CompletedAt",
                value: new DateTime(2026, 8, 28, 10, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 14,
                column: "CompletedAt",
                value: new DateTime(2026, 9, 5, 11, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 15,
                column: "CompletedAt",
                value: new DateTime(2026, 9, 5, 12, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 21,
                columns: new[] { "CompletedAt", "ReservationDate" },
                values: new object[] { new DateTime(2026, 9, 7, 20, 0, 0, 0, DateTimeKind.Utc), new DateOnly(2026, 9, 7) });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 22,
                column: "ReservationDate",
                value: new DateOnly(2026, 9, 14));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 23,
                column: "ReservationDate",
                value: new DateOnly(2026, 9, 21));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 24,
                column: "ReservationDate",
                value: new DateOnly(2026, 9, 28));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 25,
                column: "ReservationDate",
                value: new DateOnly(2026, 10, 5));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 26,
                column: "ReservationDate",
                value: new DateOnly(2026, 10, 12));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 27,
                column: "ReservationDate",
                value: new DateOnly(2026, 10, 19));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 28,
                column: "ReservationDate",
                value: new DateOnly(2026, 10, 26));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 29,
                column: "ReservationDate",
                value: new DateOnly(2026, 11, 2));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 30,
                column: "ReservationDate",
                value: new DateOnly(2026, 11, 9));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 31,
                column: "CompletedAt",
                value: new DateTime(2026, 6, 1, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 32,
                column: "CompletedAt",
                value: new DateTime(2026, 6, 8, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 33,
                column: "CompletedAt",
                value: new DateTime(2026, 6, 15, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 34,
                column: "CompletedAt",
                value: new DateTime(2026, 6, 22, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 35,
                column: "CompletedAt",
                value: new DateTime(2026, 6, 29, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 36,
                column: "CompletedAt",
                value: new DateTime(2026, 7, 6, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 37,
                column: "CompletedAt",
                value: new DateTime(2026, 7, 13, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 38,
                column: "CompletedAt",
                value: new DateTime(2026, 7, 20, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 39,
                column: "CompletedAt",
                value: new DateTime(2026, 7, 27, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 40,
                column: "CompletedAt",
                value: new DateTime(2026, 8, 3, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 41,
                columns: new[] { "CompletedAt", "ReservationDate" },
                values: new object[] { new DateTime(2026, 9, 7, 11, 0, 0, 0, DateTimeKind.Utc), new DateOnly(2026, 9, 7) });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 42,
                column: "ReservationDate",
                value: new DateOnly(2026, 9, 14));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 43,
                column: "ReservationDate",
                value: new DateOnly(2026, 9, 21));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 44,
                column: "CompletedAt",
                value: new DateTime(2026, 6, 1, 11, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 45,
                column: "CompletedAt",
                value: new DateTime(2026, 6, 8, 11, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 46,
                column: "CompletedAt",
                value: new DateTime(2026, 6, 15, 11, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 49,
                column: "CompletedAt",
                value: new DateTime(2026, 7, 2, 8, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 50,
                column: "CompletedAt",
                value: new DateTime(2026, 7, 9, 12, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 51,
                column: "CompletedAt",
                value: new DateTime(2026, 7, 21, 19, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 52,
                column: "CompletedAt",
                value: new DateTime(2026, 8, 4, 10, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 53,
                column: "CompletedAt",
                value: new DateTime(2026, 8, 13, 15, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 54,
                column: "CompletedAt",
                value: new DateTime(2026, 8, 25, 20, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 55,
                column: "CompletedAt",
                value: new DateTime(2026, 9, 3, 9, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 58,
                column: "CompletedAt",
                value: new DateTime(2026, 7, 7, 9, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 59,
                column: "CompletedAt",
                value: new DateTime(2026, 7, 16, 13, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 60,
                column: "CompletedAt",
                value: new DateTime(2026, 7, 28, 18, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 61,
                column: "CompletedAt",
                value: new DateTime(2026, 8, 6, 8, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 62,
                column: "CompletedAt",
                value: new DateTime(2026, 8, 18, 11, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 63,
                column: "CompletedAt",
                value: new DateTime(2026, 8, 27, 16, 0, 0, 0, DateTimeKind.Utc));

            migrationBuilder.InsertData(
                table: "Reservations",
                columns: new[] { "Id", "CanceledAt", "CancellationDeadline", "CancellationReason", "ChosenSportId", "CompletedAt", "EndTime", "FacilityId", "PaymentMethod", "Price", "ReservationDate", "StartTime", "Status", "UserId" },
                values: new object[] { 67, new DateTime(2026, 9, 2, 18, 0, 0, 0, DateTimeKind.Utc), null, "Can't come, sorry", 2, null, new TimeOnly(19, 0, 0), 5, null, 30.00m, new DateOnly(2026, 9, 3), new TimeOnly(18, 0, 0), "CanceledReservationState", 2 });

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 1,
                column: "ContactEmail",
                value: "stadion_grbavica@example.com");

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 2,
                column: "ContactEmail",
                value: "basketball_arena@example.com");

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 3,
                column: "ContactEmail",
                value: "tennis_club_tuzla@example.com");

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 4,
                column: "ContactEmail",
                value: "skenderija@example.com");

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 5,
                column: "ContactEmail",
                value: "mostar_indoor_arena@example.com");

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 6,
                column: "ContactEmail",
                value: "zenica_sports_center@example.com");

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 7,
                column: "ContactEmail",
                value: "doboj_football_academy@example.com");

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 8,
                column: "ContactEmail",
                value: "konjic_tennis_complex@example.com");

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 9,
                column: "ContactEmail",
                value: "travnik_indoor_arena@example.com");

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 10,
                column: "ContactEmail",
                value: "ramiz_salcin@example.com");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "FavoriteSportCenters",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "FavoriteSportCenters",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "FavoriteSportCenters",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "FavoriteSportCenters",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 67);

            migrationBuilder.UpdateData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "CanceledAt", "Reason" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 11,
                columns: new[] { "CanceledAt", "Reason" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 1,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 2,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 3,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 4,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 5,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 6,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 7,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 8,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 9,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 10,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 11,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 12,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 13,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 14,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 15,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 21,
                columns: new[] { "CompletedAt", "ReservationDate" },
                values: new object[] { null, new DateOnly(2026, 9, 1) });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 22,
                column: "ReservationDate",
                value: new DateOnly(2026, 9, 8));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 23,
                column: "ReservationDate",
                value: new DateOnly(2026, 9, 15));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 24,
                column: "ReservationDate",
                value: new DateOnly(2026, 9, 22));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 25,
                column: "ReservationDate",
                value: new DateOnly(2026, 9, 29));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 26,
                column: "ReservationDate",
                value: new DateOnly(2026, 10, 6));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 27,
                column: "ReservationDate",
                value: new DateOnly(2026, 10, 13));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 28,
                column: "ReservationDate",
                value: new DateOnly(2026, 10, 20));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 29,
                column: "ReservationDate",
                value: new DateOnly(2026, 10, 27));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 30,
                column: "ReservationDate",
                value: new DateOnly(2026, 11, 3));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 31,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 32,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 33,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 34,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 35,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 36,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 37,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 38,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 39,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 40,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 41,
                columns: new[] { "CompletedAt", "ReservationDate" },
                values: new object[] { null, new DateOnly(2026, 9, 1) });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 42,
                column: "ReservationDate",
                value: new DateOnly(2026, 9, 8));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 43,
                column: "ReservationDate",
                value: new DateOnly(2026, 9, 15));

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 44,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 45,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 46,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 49,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 50,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 51,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 52,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 53,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 54,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 55,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 58,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 59,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 60,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 61,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 62,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 63,
                column: "CompletedAt",
                value: null);

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 1,
                column: "ContactEmail",
                value: null);

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 2,
                column: "ContactEmail",
                value: null);

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 3,
                column: "ContactEmail",
                value: null);

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 4,
                column: "ContactEmail",
                value: null);

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 5,
                column: "ContactEmail",
                value: null);

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 6,
                column: "ContactEmail",
                value: null);

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 7,
                column: "ContactEmail",
                value: null);

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 8,
                column: "ContactEmail",
                value: null);

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 9,
                column: "ContactEmail",
                value: null);

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 10,
                column: "ContactEmail",
                value: null);
        }
    }
}
