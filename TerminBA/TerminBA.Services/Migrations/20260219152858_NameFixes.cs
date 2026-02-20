using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class NameFixes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "SportName",
                table: "Sports",
                newName: "Name");

            migrationBuilder.RenameColumn(
                name: "RoleName",
                table: "Roles",
                newName: "Name");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Name",
                table: "Sports",
                newName: "SportName");

            migrationBuilder.RenameColumn(
                name: "Name",
                table: "Roles",
                newName: "RoleName");
        }
    }
}
