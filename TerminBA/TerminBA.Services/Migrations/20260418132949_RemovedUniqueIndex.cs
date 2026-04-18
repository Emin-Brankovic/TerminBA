using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class RemovedUniqueIndex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_UserReviews_ReviewerId_ReviewedId",
                table: "UserReviews");

            migrationBuilder.DropIndex(
                name: "IX_Reservations_FacilityId_ReservationDate_StartTime",
                table: "Reservations");

            migrationBuilder.DropIndex(
                name: "IX_PlayRequests_PostId_RequesterId",
                table: "PlayRequests");

            migrationBuilder.DropIndex(
                name: "IX_FacilityReviews_UserId_FacilityId",
                table: "FacilityReviews");

            migrationBuilder.CreateIndex(
                name: "IX_UserReviews_ReviewerId_ReviewedId",
                table: "UserReviews",
                columns: new[] { "ReviewerId", "ReviewedId" });

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_FacilityId_ReservationDate_StartTime",
                table: "Reservations",
                columns: new[] { "FacilityId", "ReservationDate", "StartTime" });

            migrationBuilder.CreateIndex(
                name: "IX_PlayRequests_PostId_RequesterId",
                table: "PlayRequests",
                columns: new[] { "PostId", "RequesterId" });

            migrationBuilder.CreateIndex(
                name: "IX_FacilityReviews_UserId_FacilityId",
                table: "FacilityReviews",
                columns: new[] { "UserId", "FacilityId" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_UserReviews_ReviewerId_ReviewedId",
                table: "UserReviews");

            migrationBuilder.DropIndex(
                name: "IX_Reservations_FacilityId_ReservationDate_StartTime",
                table: "Reservations");

            migrationBuilder.DropIndex(
                name: "IX_PlayRequests_PostId_RequesterId",
                table: "PlayRequests");

            migrationBuilder.DropIndex(
                name: "IX_FacilityReviews_UserId_FacilityId",
                table: "FacilityReviews");

            migrationBuilder.CreateIndex(
                name: "IX_UserReviews_ReviewerId_ReviewedId",
                table: "UserReviews",
                columns: new[] { "ReviewerId", "ReviewedId" },
                unique: true,
                filter: "[ReviewerId] IS NOT NULL AND [ReviewedId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_FacilityId_ReservationDate_StartTime",
                table: "Reservations",
                columns: new[] { "FacilityId", "ReservationDate", "StartTime" },
                unique: true,
                filter: "[FacilityId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_PlayRequests_PostId_RequesterId",
                table: "PlayRequests",
                columns: new[] { "PostId", "RequesterId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_FacilityReviews_UserId_FacilityId",
                table: "FacilityReviews",
                columns: new[] { "UserId", "FacilityId" },
                unique: true,
                filter: "[UserId] IS NOT NULL AND [FacilityId] IS NOT NULL");
        }
    }
}
