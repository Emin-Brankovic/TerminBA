using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class ReservationAuditLogUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CanceledBySportCenterId",
                table: "Reservations",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CanceledByUserId",
                table: "Reservations",
                type: "int",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 10,
                column: "PostState",
                value: "FinishedPostState");

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 9,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 10,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 11,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 12,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 13,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 14,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 15,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 16,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 17,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 18,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 19,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 20,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 21,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 22,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 23,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 24,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId", "CompletedAt", "Status" },
                values: new object[] { null, null, new DateTime(2026, 9, 28, 20, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 25,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 26,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 27,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 28,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 29,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 30,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 31,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 32,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 33,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 34,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 35,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 36,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 37,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 38,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 39,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 40,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 41,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 42,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 43,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 44,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 45,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 46,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 47,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 48,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 49,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 50,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 51,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 52,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 53,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 54,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 55,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 56,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 57,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId", "CompletedAt", "Status" },
                values: new object[] { null, null, new DateTime(2026, 9, 29, 18, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 58,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 59,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 60,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 61,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 62,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 63,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 64,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 65,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 66,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId", "CompletedAt", "Status" },
                values: new object[] { null, null, new DateTime(2026, 9, 24, 20, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 67,
                columns: new[] { "CanceledBySportCenterId", "CanceledByUserId" },
                values: new object[] { null, null });

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_CanceledBySportCenterId",
                table: "Reservations",
                column: "CanceledBySportCenterId");

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_CanceledByUserId",
                table: "Reservations",
                column: "CanceledByUserId");

            migrationBuilder.AddForeignKey(
                name: "FK_Reservations_SportCenters_CanceledBySportCenterId",
                table: "Reservations",
                column: "CanceledBySportCenterId",
                principalTable: "SportCenters",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Reservations_Users_CanceledByUserId",
                table: "Reservations",
                column: "CanceledByUserId",
                principalTable: "Users",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Reservations_SportCenters_CanceledBySportCenterId",
                table: "Reservations");

            migrationBuilder.DropForeignKey(
                name: "FK_Reservations_Users_CanceledByUserId",
                table: "Reservations");

            migrationBuilder.DropIndex(
                name: "IX_Reservations_CanceledBySportCenterId",
                table: "Reservations");

            migrationBuilder.DropIndex(
                name: "IX_Reservations_CanceledByUserId",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "CanceledBySportCenterId",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "CanceledByUserId",
                table: "Reservations");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 10,
                column: "PostState",
                value: "PlayerFoundPostState");

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 24,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 57,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 66,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });
        }
    }
}
