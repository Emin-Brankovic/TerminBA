using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class FacilityReviewUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ReservationId",
                table: "FacilityReviews",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_FacilityReviews_ReservationId",
                table: "FacilityReviews",
                column: "ReservationId",
                unique: true,
                filter: "[ReservationId] IS NOT NULL");

            migrationBuilder.AddForeignKey(
                name: "FK_FacilityReviews_Reservations_ReservationId",
                table: "FacilityReviews",
                column: "ReservationId",
                principalTable: "Reservations",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_FacilityReviews_Reservations_ReservationId",
                table: "FacilityReviews");

            migrationBuilder.DropIndex(
                name: "IX_FacilityReviews_ReservationId",
                table: "FacilityReviews");

            migrationBuilder.DropColumn(
                name: "ReservationId",
                table: "FacilityReviews");
        }
    }
}
