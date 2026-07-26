using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class RecommendationEvents : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "RecommendationEvents",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    FacilityId = table.Column<int>(type: "int", nullable: false),
                    CandidateStart = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CandidateEnd = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Score = table.Column<float>(type: "real", nullable: false),
                    ExplanationJson = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    WasClicked = table.Column<bool>(type: "bit", nullable: false),
                    WasBooked = table.Column<bool>(type: "bit", nullable: false),
                    ShownAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RecommendationEvents", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RecommendationEvents_Facilities_FacilityId",
                        column: x => x.FacilityId,
                        principalTable: "Facilities",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_RecommendationEvents_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_RecommendationEvents_FacilityId",
                table: "RecommendationEvents",
                column: "FacilityId");

            migrationBuilder.CreateIndex(
                name: "IX_RecommendationEvents_ShownAt",
                table: "RecommendationEvents",
                column: "ShownAt");

            migrationBuilder.CreateIndex(
                name: "IX_RecommendationEvents_UserId",
                table: "RecommendationEvents",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RecommendationEvents");
        }
    }
}
