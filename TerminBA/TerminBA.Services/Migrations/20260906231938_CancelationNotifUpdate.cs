using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class CancelationNotifUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Reason",
                table: "CancelationNotifications",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "CancelationNotifications",
                keyColumn: "Id",
                keyValue: 1,
                column: "Reason",
                value: null);

            migrationBuilder.UpdateData(
                table: "CancelationNotifications",
                keyColumn: "Id",
                keyValue: 2,
                column: "Reason",
                value: null);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Reason",
                table: "CancelationNotifications");
        }
    }
}
