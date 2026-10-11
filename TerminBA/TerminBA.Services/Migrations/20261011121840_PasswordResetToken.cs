using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class PasswordResetToken : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PasswordResetToken",
                table: "Users",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "PasswordResetTokenExpiresAt",
                table: "Users",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PasswordResetToken",
                table: "SportCenters",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "PasswordResetTokenExpiresAt",
                table: "SportCenters",
                type: "datetime2",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 11,
                column: "PostState",
                value: "FinishedPostState");

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 16,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { new DateTime(2026, 10, 10, 18, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 17,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { new DateTime(2026, 10, 10, 19, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 25,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { new DateTime(2026, 10, 5, 20, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 9,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 10,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 9,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 10,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 11,
                columns: new[] { "PasswordResetToken", "PasswordResetTokenExpiresAt" },
                values: new object[] { null, null });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PasswordResetToken",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "PasswordResetTokenExpiresAt",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "PasswordResetToken",
                table: "SportCenters");

            migrationBuilder.DropColumn(
                name: "PasswordResetTokenExpiresAt",
                table: "SportCenters");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 11,
                column: "PostState",
                value: "PlayerSearchPostState");

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 16,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 17,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 25,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });
        }
    }
}
