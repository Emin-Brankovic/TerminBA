using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class UserReview : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ReservationId",
                table: "UserReviews",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserReviews_ReservationId",
                table: "UserReviews",
                column: "ReservationId");

            migrationBuilder.AddForeignKey(
                name: "FK_UserReviews_Reservations_ReservationId",
                table: "UserReviews",
                column: "ReservationId",
                principalTable: "Reservations",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_UserReviews_Reservations_ReservationId",
                table: "UserReviews");

            migrationBuilder.DropIndex(
                name: "IX_UserReviews_ReservationId",
                table: "UserReviews");

            migrationBuilder.DropColumn(
                name: "ReservationId",
                table: "UserReviews");
        }
    }
}
