using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class SportCenterLocation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "Latitude",
                table: "SportCenters",
                type: "decimal(12,10)",
                precision: 12,
                scale: 10,
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Longitude",
                table: "SportCenters",
                type: "decimal(13,10)",
                precision: 13,
                scale: 10,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Latitude",
                table: "SportCenters");

            migrationBuilder.DropColumn(
                name: "Longitude",
                table: "SportCenters");
        }
    }
}
