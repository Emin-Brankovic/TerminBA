using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class PlayRequestNotification : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsSeenByOwner",
                table: "PlayRequests",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsSeenByRequester",
                table: "PlayRequests",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsSeenByOwner",
                table: "PlayRequests");

            migrationBuilder.DropColumn(
                name: "IsSeenByRequester",
                table: "PlayRequests");
        }
    }
}
