using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class StripRefund : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CancellationDeadlineHours",
                table: "SportCenters",
                type: "int",
                nullable: false,
                defaultValue: 24);

            migrationBuilder.AddColumn<DateTime>(
                name: "CanceledAt",
                table: "Reservations",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CancellationDeadline",
                table: "Reservations",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CompletedAt",
                table: "Reservations",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PaymentMethod",
                table: "Reservations",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Payments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ReservationId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Provider = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    StripePaymentIntentId = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    StripeChargeId = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    StripeRefundId = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    Amount = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    Currency = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    RefundAmount = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    PaidAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    RefundRequestedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    RefundedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Metadata = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Payments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Payments_Reservations_ReservationId",
                        column: x => x.ReservationId,
                        principalTable: "Reservations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Payments_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Payments_ReservationId",
                table: "Payments",
                column: "ReservationId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_UserId",
                table: "Payments",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Payments");

            migrationBuilder.DropColumn(
                name: "CancellationDeadlineHours",
                table: "SportCenters");

            migrationBuilder.DropColumn(
                name: "CanceledAt",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "CancellationDeadline",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "CompletedAt",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "PaymentMethod",
                table: "Reservations");
        }
    }
}
