using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class DynamicPrices : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PricePerHour",
                table: "Facilities");

            migrationBuilder.AlterColumn<DateOnly>(
                name: "ValidTo",
                table: "WorkingHours",
                type: "date",
                nullable: true,
                oldClrType: typeof(DateOnly),
                oldType: "date");

            migrationBuilder.AddColumn<bool>(
                name: "IsDynamicPricing",
                table: "Facilities",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<decimal>(
                name: "StaticPrice",
                table: "Facilities",
                type: "decimal(10,2)",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "FacilityDynamicPrices",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FacilityId = table.Column<int>(type: "int", nullable: false),
                    StartDay = table.Column<int>(type: "int", nullable: false),
                    EndDay = table.Column<int>(type: "int", nullable: false),
                    StartTime = table.Column<TimeOnly>(type: "time", nullable: false),
                    EndTime = table.Column<TimeOnly>(type: "time", nullable: false),
                    PricePerHour = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    ValidFrom = table.Column<DateOnly>(type: "date", nullable: false),
                    ValidTo = table.Column<DateOnly>(type: "date", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FacilityDynamicPrices", x => x.Id);
                    table.ForeignKey(
                        name: "FK_FacilityDynamicPrices_Facilities_FacilityId",
                        column: x => x.FacilityId,
                        principalTable: "Facilities",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_FacilityDynamicPrices_FacilityId",
                table: "FacilityDynamicPrices",
                column: "FacilityId");

            migrationBuilder.CreateIndex(
                name: "IX_FacilityDynamicPrices_FacilityId_ValidFrom_ValidTo",
                table: "FacilityDynamicPrices",
                columns: new[] { "FacilityId", "ValidFrom", "ValidTo" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "FacilityDynamicPrices");

            migrationBuilder.DropColumn(
                name: "IsDynamicPricing",
                table: "Facilities");

            migrationBuilder.DropColumn(
                name: "StaticPrice",
                table: "Facilities");

            migrationBuilder.AlterColumn<DateOnly>(
                name: "ValidTo",
                table: "WorkingHours",
                type: "date",
                nullable: false,
                defaultValue: new DateOnly(1, 1, 1),
                oldClrType: typeof(DateOnly),
                oldType: "date",
                oldNullable: true);

            migrationBuilder.AddColumn<double>(
                name: "PricePerHour",
                table: "Facilities",
                type: "float",
                nullable: false,
                defaultValue: 0.0);
        }
    }
}
