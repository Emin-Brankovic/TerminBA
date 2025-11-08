using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class PlayRequestAdded : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_FacilityReviews_FacilityReviews_FacilityReviewId",
                table: "FacilityReviews");

            migrationBuilder.DropIndex(
                name: "IX_FacilityReviews_FacilityReviewId",
                table: "FacilityReviews");

            migrationBuilder.DropColumn(
                name: "FacilityReviewId",
                table: "FacilityReviews");

            migrationBuilder.CreateTable(
                name: "PlayRequests",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PostId = table.Column<int>(type: "int", nullable: false),
                    RequesterId = table.Column<int>(type: "int", nullable: false),
                    isAccepted = table.Column<bool>(type: "bit", nullable: true),
                    RequestText = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    DateOfRequest = table.Column<DateTime>(type: "datetime2", nullable: false),
                    DateOfResponse = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlayRequests", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PlayRequests_Posts_PostId",
                        column: x => x.PostId,
                        principalTable: "Posts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PlayRequests_Users_RequesterId",
                        column: x => x.RequesterId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PlayRequests_PostId",
                table: "PlayRequests",
                column: "PostId");

            migrationBuilder.CreateIndex(
                name: "IX_PlayRequests_PostId_RequesterId",
                table: "PlayRequests",
                columns: new[] { "PostId", "RequesterId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PlayRequests_RequesterId",
                table: "PlayRequests",
                column: "RequesterId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PlayRequests");

            migrationBuilder.AddColumn<int>(
                name: "FacilityReviewId",
                table: "FacilityReviews",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_FacilityReviews_FacilityReviewId",
                table: "FacilityReviews",
                column: "FacilityReviewId");

            migrationBuilder.AddForeignKey(
                name: "FK_FacilityReviews_FacilityReviews_FacilityReviewId",
                table: "FacilityReviews",
                column: "FacilityReviewId",
                principalTable: "FacilityReviews",
                principalColumn: "Id");
        }
    }
}
