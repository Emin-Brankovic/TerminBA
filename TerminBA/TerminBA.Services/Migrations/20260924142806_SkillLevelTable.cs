using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class SkillLevelTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "SkillLevels",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SkillLevels", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "SkillLevels",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Beginner" },
                    { 2, "Medium" },
                    { 3, "Advanced" }
                });

            migrationBuilder.AddColumn<int>(
                name: "SkillLevelId",
                table: "Posts",
                type: "int",
                nullable: false,
                defaultValue: 2); // Default to Medium

            migrationBuilder.Sql("UPDATE Posts SET SkillLevelId = 1 WHERE SkillLevel = 'Beginner'");
            migrationBuilder.Sql("UPDATE Posts SET SkillLevelId = 2 WHERE SkillLevel = 'Medium'");
            migrationBuilder.Sql("UPDATE Posts SET SkillLevelId = 3 WHERE SkillLevel = 'Advanced' OR SkillLevel = 'Advance'");

            migrationBuilder.DropIndex(
                name: "IX_Posts_SkillLevel",
                table: "Posts");

            migrationBuilder.DropColumn(
                name: "SkillLevel",
                table: "Posts");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 1,
                column: "SkillLevelId",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 2,
                column: "SkillLevelId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 3,
                column: "SkillLevelId",
                value: 3);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 4,
                column: "SkillLevelId",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 5,
                column: "SkillLevelId",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 6,
                column: "SkillLevelId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 7,
                column: "SkillLevelId",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "PostState", "SkillLevelId" },
                values: new object[] { "FinishedPostState", 2 });

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 9,
                columns: new[] { "PostState", "SkillLevelId" },
                values: new object[] { "FinishedPostState", 2 });

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 10,
                column: "SkillLevelId",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 11,
                column: "SkillLevelId",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 12,
                column: "SkillLevelId",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 13,
                column: "SkillLevelId",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 14,
                column: "SkillLevelId",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 15,
                column: "SkillLevelId",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 16,
                column: "SkillLevelId",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 17,
                column: "SkillLevelId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 18,
                columns: new[] { "PostState", "SkillLevelId" },
                values: new object[] { "FinishedPostState", 2 });

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 19,
                columns: new[] { "PostState", "SkillLevelId" },
                values: new object[] { "FinishedPostState", 2 });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 22,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { new DateTime(2026, 9, 14, 20, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 23,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { new DateTime(2026, 9, 21, 20, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 42,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { new DateTime(2026, 9, 14, 11, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 43,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { new DateTime(2026, 9, 21, 11, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 47,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { new DateTime(2026, 9, 17, 17, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 48,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { new DateTime(2026, 9, 19, 18, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 56,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { new DateTime(2026, 9, 15, 14, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 64,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { new DateTime(2026, 9, 8, 10, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 65,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { new DateTime(2026, 9, 17, 15, 0, 0, 0, DateTimeKind.Utc), "CompletedReservationState" });



            migrationBuilder.CreateIndex(
                name: "IX_Posts_SkillLevelId",
                table: "Posts",
                column: "SkillLevelId");

            migrationBuilder.AddForeignKey(
                name: "FK_Posts_SkillLevels_SkillLevelId",
                table: "Posts",
                column: "SkillLevelId",
                principalTable: "SkillLevels",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Posts_SkillLevels_SkillLevelId",
                table: "Posts");

            migrationBuilder.DropTable(
                name: "SkillLevels");

            migrationBuilder.DropIndex(
                name: "IX_Posts_SkillLevelId",
                table: "Posts");

            migrationBuilder.DropColumn(
                name: "SkillLevelId",
                table: "Posts");

            migrationBuilder.AddColumn<string>(
                name: "SkillLevel",
                table: "Posts",
                type: "nvarchar(450)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 1,
                column: "SkillLevel",
                value: "Medium");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 2,
                column: "SkillLevel",
                value: "Beginner");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 3,
                column: "SkillLevel",
                value: "Advanced");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 4,
                column: "SkillLevel",
                value: "Medium");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 5,
                column: "SkillLevel",
                value: "Medium");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 6,
                column: "SkillLevel",
                value: "Beginner");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 7,
                column: "SkillLevel",
                value: "Medium");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "PostState", "SkillLevel" },
                values: new object[] { "PlayerFoundPostState", "Medium" });

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 9,
                columns: new[] { "PostState", "SkillLevel" },
                values: new object[] { "PlayerSearchPostState", "Medium" });

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 10,
                column: "SkillLevel",
                value: "Medium");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 11,
                column: "SkillLevel",
                value: "Medium");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 12,
                column: "SkillLevel",
                value: "Medium");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 13,
                column: "SkillLevel",
                value: "Medium");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 14,
                column: "SkillLevel",
                value: "Medium");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 15,
                column: "SkillLevel",
                value: "Medium");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 16,
                column: "SkillLevel",
                value: "Medium");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 17,
                column: "SkillLevel",
                value: "Beginner");

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 18,
                columns: new[] { "PostState", "SkillLevel" },
                values: new object[] { "PlayerSearchPostState", "Medium" });

            migrationBuilder.UpdateData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 19,
                columns: new[] { "PostState", "SkillLevel" },
                values: new object[] { "PlayerFoundPostState", "Medium" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 22,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 23,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 42,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 43,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 47,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 48,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 56,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 64,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 65,
                columns: new[] { "CompletedAt", "Status" },
                values: new object[] { null, "ActiveReservationState" });

            migrationBuilder.CreateIndex(
                name: "IX_Posts_SkillLevel",
                table: "Posts",
                column: "SkillLevel");
        }
    }
}
