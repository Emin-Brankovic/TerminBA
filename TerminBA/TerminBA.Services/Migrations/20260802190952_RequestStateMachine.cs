using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class RequestStateMachine : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "isAccepted",
                table: "PlayRequests");

            migrationBuilder.AddColumn<DateTime>(
                name: "CanceledAt",
                table: "PlayRequests",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CanceledById",
                table: "PlayRequests",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PlayRequestState",
                table: "PlayRequests",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Reason",
                table: "PlayRequests",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "RespondedAt",
                table: "PlayRequests",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RespondedById",
                table: "PlayRequests",
                type: "int",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CanceledAt",
                table: "PlayRequests");

            migrationBuilder.DropColumn(
                name: "CanceledById",
                table: "PlayRequests");

            migrationBuilder.DropColumn(
                name: "PlayRequestState",
                table: "PlayRequests");

            migrationBuilder.DropColumn(
                name: "Reason",
                table: "PlayRequests");

            migrationBuilder.DropColumn(
                name: "RespondedAt",
                table: "PlayRequests");

            migrationBuilder.DropColumn(
                name: "RespondedById",
                table: "PlayRequests");

            migrationBuilder.AddColumn<bool>(
                name: "isAccepted",
                table: "PlayRequests",
                type: "bit",
                nullable: true);
        }
    }
}
