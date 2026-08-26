using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace TerminBA.Services.Migrations
{
    /// <inheritdoc />
    public partial class DbSeed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Amenity",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Parking" },
                    { 2, "Locker Room" },
                    { 3, "Shower" },
                    { 4, "Cafeteria" },
                    { 5, "WiFi" },
                    { 6, "First Aid" }
                });

            migrationBuilder.InsertData(
                table: "Cities",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Sarajevo" },
                    { 2, "Banja Luka" },
                    { 3, "Tuzla" },
                    { 4, "Zenica" },
                    { 5, "Mostar" },
                    { 6, "Konjic" },
                    { 7, "Travnik" },
                    { 8, "Doboj" }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "Name", "RoleDescription" },
                values: new object[,]
                {
                    { 1, "User", "Regular user who can make reservations" },
                    { 2, "Sport center", "Owner of a sport center" },
                    { 3, "Administrator", "Administrator with full system access" }
                });

            migrationBuilder.InsertData(
                table: "Sports",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Football" },
                    { 2, "Basketball" },
                    { 3, "Tennis" },
                    { 4, "Volleyball" },
                    { 5, "Handball" }
                });

            migrationBuilder.InsertData(
                table: "TurfTypes",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Natural Grass" },
                    { 2, "Artificial Grass" },
                    { 3, "Hardwood" },
                    { 4, "Clay" },
                    { 5, "Tartan" }
                });

            migrationBuilder.InsertData(
                table: "SportCenters",
                columns: new[] { "Id", "Address", "CancellationDeadlineHours", "CityId", "ContactEmail", "CreatedAt", "Description", "DisplayName", "InstagramAccount", "IsEquipmentProvided", "Latitude", "Longitude", "PasswordHash", "PasswordSalt", "PhoneNumber", "RoleId", "UpdatedAt", "Username" },
                values: new object[,]
                {
                    { 1, "Grbavica 1, Sarajevo", 24, 1, null, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Premier football stadium with modern facilities", "Stadion Grbavica", null, true, 43.846670m, 18.387220m, "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123470", 2, null, "stadion_grbavica" },
                    { 2, "Centar, Banja Luka", 24, 2, null, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Professional basketball court with indoor facilities", "Basketball Arena", null, true, 44.772181m, 17.191000m, "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123471", 2, null, "basketball_arena" },
                    { 3, "Slatina, Tuzla", 24, 3, null, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Outdoor tennis courts with clay and hard court surfaces", "Tennis Club Tuzla", null, false, 44.541390m, 18.665000m, "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123472", 2, null, "tennis_club_tuzla" },
                    { 4, "Terezija bb, Sarajevo", 24, 1, null, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Huge indoor complex in the heart of Sarajevo", "Skenderija", null, true, 43.8554721469m, 18.4143950288m, "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123473", 2, null, "skenderija" },
                    { 5, "Zalik, Mostar", 24, 5, null, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Great indoor arena for various sports", "Mostar Indoor Arena", null, true, 43.357300m, 17.819800m, "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123474", 2, null, "mostar_indoor_arena" },
                    { 6, "Kamberovica polje, Zenica", 24, 4, null, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Main sports complex in Zenica", "Zenica Sports Center", null, true, 44.203823m, 17.910900m, "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123475", 2, null, "zenica_sports_center" },
                    { 7, "Usora, Doboj", 24, 8, null, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Top football academy with multiple fields", "Doboj Football Academy", null, true, 44.736000m, 18.087900m, "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123476", 2, null, "doboj_football_academy" },
                    { 8, "Koviljuse, Konjic", 24, 6, null, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Large complex of professional tennis courts", "Konjic Tennis Complex", null, false, 43.623000m, 17.952000m, "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123477", 2, null, "konjic_tennis_complex" },
                    { 9, "Pecani, Travnik", 24, 7, null, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Modern indoor arena for multiple sports", "Travnik Indoor Arena", null, true, 44.219500m, 17.670900m, "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123478", 2, null, "travnik_indoor_arena" },
                    { 10, "Semira Frašte 21, Sarajevo", 24, 1, null, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Large sports complex with multi-purpose courts", "Ramiz Salcin", null, true, 43.849570m, 18.360830m, "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123479", 2, null, "ramiz_salcin" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "BirthDate", "CityId", "CreatedAt", "Email", "FirstName", "InstagramAccount", "LastName", "PasswordHash", "PasswordSalt", "PhoneNumber", "RoleId", "UpdatedAt", "Username" },
                values: new object[,]
                {
                    { 1, new DateOnly(1999, 1, 1), 1, new DateTime(2025, 12, 5, 10, 0, 0, 0, DateTimeKind.Utc), "admin@gmail.com", "Admin", null, "Admin", "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123456", 3, new DateTime(2025, 12, 5, 10, 0, 0, 0, DateTimeKind.Utc), "admin" },
                    { 2, new DateOnly(1999, 1, 1), 1, new DateTime(2026, 1, 15, 12, 0, 0, 0, DateTimeKind.Utc), "emin.brankovic@edu.fit.ba", "Test", null, "User", "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123456", 1, new DateTime(2026, 1, 15, 12, 0, 0, 0, DateTimeKind.Utc), "user" },
                    { 3, new DateOnly(1999, 1, 1), 2, new DateTime(2026, 2, 20, 14, 0, 0, 0, DateTimeKind.Utc), "jasna.kovacevic@example.com", "Jasna", null, "Kovacevic", "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123457", 1, new DateTime(2026, 2, 20, 14, 0, 0, 0, DateTimeKind.Utc), "jasna.kovacevic" },
                    { 4, new DateOnly(1999, 1, 1), 3, new DateTime(2026, 3, 10, 9, 0, 0, 0, DateTimeKind.Utc), "nermin.delic@example.com", "Nermin", null, "Delic", "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123458", 1, new DateTime(2026, 3, 10, 9, 0, 0, 0, DateTimeKind.Utc), "nermin.delic" },
                    { 5, new DateOnly(1999, 1, 1), 1, new DateTime(2026, 4, 5, 11, 0, 0, 0, DateTimeKind.Utc), "ivana.juric@example.com", "Ivana", null, "Juric", "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123459", 1, new DateTime(2026, 4, 5, 11, 0, 0, 0, DateTimeKind.Utc), "ivana.juric" },
                    { 6, new DateOnly(1999, 1, 1), 2, new DateTime(2026, 5, 25, 16, 0, 0, 0, DateTimeKind.Utc), "adnan.begovic@example.com", "Adnan", null, "Begovic", "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123460", 1, new DateTime(2026, 5, 25, 16, 0, 0, 0, DateTimeKind.Utc), "adnan.begovic" },
                    { 7, new DateOnly(1999, 1, 1), 3, new DateTime(2026, 6, 1, 10, 0, 0, 0, DateTimeKind.Utc), "lejla.halilovic@example.com", "Lejla", null, "Halilovic", "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123461", 1, new DateTime(2026, 6, 1, 10, 0, 0, 0, DateTimeKind.Utc), "lejla.halilovic" },
                    { 8, new DateOnly(1999, 1, 1), 1, new DateTime(2026, 7, 12, 13, 0, 0, 0, DateTimeKind.Utc), "haris.mujanovic@example.com", "Haris", null, "Mujanovic", "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123462", 1, new DateTime(2026, 7, 12, 13, 0, 0, 0, DateTimeKind.Utc), "haris.mujanovic" },
                    { 9, new DateOnly(1999, 1, 1), 2, new DateTime(2026, 8, 2, 15, 0, 0, 0, DateTimeKind.Utc), "selma.djuric@example.com", "Selma", null, "Djuric", "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123463", 1, new DateTime(2026, 8, 2, 15, 0, 0, 0, DateTimeKind.Utc), "selma.djuric" },
                    { 10, new DateOnly(1999, 1, 1), 3, new DateTime(2026, 8, 10, 8, 0, 0, 0, DateTimeKind.Utc), "emina.hasanovic@example.com", "Emina", null, "Hasanovic", "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123464", 1, new DateTime(2026, 8, 10, 8, 0, 0, 0, DateTimeKind.Utc), "emina.hasanovic" },
                    { 11, new DateOnly(1999, 1, 1), 1, new DateTime(2026, 8, 20, 18, 0, 0, 0, DateTimeKind.Utc), "tarik.vukovic@example.com", "Tarik", null, "Vukovic", "IWj9UNWMPKYf2DevhJf+nrMj63VgRQ6Z7BFMphsuPR62c6bFapy3GcC6K+39gGK3nbYjkZIHmvOKoNRqL3icSQ==", "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=", "+38761123465", 1, new DateTime(2026, 8, 20, 18, 0, 0, 0, DateTimeKind.Utc), "tarik.vukovic" }
                });

            migrationBuilder.InsertData(
                table: "Facilities",
                columns: new[] { "Id", "CreatedAt", "Duration", "IsDynamicPricing", "IsIndoor", "MaxCapacity", "Name", "SportCenterId", "StaticPrice", "TurfTypeId", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 30, 0, 0), true, false, 22, "Main Football Field", 1, null, 2, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 2, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 0, 0, 0), false, true, 10, "Basketball Court A", 2, 50.00m, 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 3, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 0, 0, 0), true, false, 4, "Tennis Court 1", 3, null, 4, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 4, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 30, 0, 0), false, true, 12, "Volleyball Court", 2, 40.00m, 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 0, 0, 0), false, true, 10, "Basketball Court 1", 4, 30.00m, 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 6, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 0, 0, 0), false, true, 12, "Volleyball Area", 4, 20.00m, 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 7, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 30, 0, 0), true, true, 14, "Indoor Court", 5, null, 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 8, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 30, 0, 0), false, false, 22, "Zenica Football Field", 6, 80.00m, 2, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 9, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 0, 0, 0), false, true, 10, "Zenica Basketball Court", 6, 40.00m, 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 10, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 30, 0, 0), false, false, 22, "Doboj Main Field", 7, 60.00m, 1, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 11, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 30, 0, 0), false, false, 14, "Doboj Training Field", 7, 40.00m, 2, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 12, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 0, 0, 0), false, false, 4, "Travnik Center Court", 8, 50.00m, 4, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 13, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 0, 0, 0), false, false, 4, "Travnik Court 2", 8, 30.00m, 3, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 14, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 0, 0, 0), false, false, 4, "Travnik Court 3", 8, 30.00m, 3, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 15, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 30, 0, 0), false, true, 14, "Konjic Court", 9, 45.00m, 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 16, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 0, 0, 0), false, true, 20, "Main Court", 10, 100.00m, 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 17, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), new TimeSpan(0, 1, 0, 0, 0), false, true, 12, "Secondary Court", 10, 70.00m, 5, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc) }
                });

            migrationBuilder.InsertData(
                table: "SportCenterAmenities",
                columns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                values: new object[,]
                {
                    { 1, 1 },
                    { 1, 2 },
                    { 1, 3 },
                    { 1, 4 },
                    { 1, 5 },
                    { 1, 6 },
                    { 1, 7 },
                    { 1, 8 },
                    { 1, 9 },
                    { 1, 10 },
                    { 2, 1 },
                    { 2, 2 },
                    { 2, 3 },
                    { 2, 4 },
                    { 2, 5 },
                    { 2, 6 },
                    { 2, 8 },
                    { 2, 10 },
                    { 3, 1 },
                    { 3, 2 },
                    { 3, 3 },
                    { 3, 4 },
                    { 3, 5 },
                    { 3, 6 },
                    { 3, 9 },
                    { 3, 10 },
                    { 4, 1 },
                    { 4, 2 },
                    { 4, 3 },
                    { 4, 5 },
                    { 4, 8 },
                    { 4, 10 },
                    { 5, 1 },
                    { 5, 2 },
                    { 5, 4 },
                    { 5, 9 },
                    { 5, 10 },
                    { 6, 1 },
                    { 6, 2 },
                    { 6, 3 },
                    { 6, 4 },
                    { 6, 5 },
                    { 6, 7 },
                    { 6, 10 }
                });

            migrationBuilder.InsertData(
                table: "SportCenterPhotos",
                columns: new[] { "Id", "PublicId", "SportCenterId", "Url" },
                values: new object[,]
                {
                    { 1, "stadion_grbavica_1", 1, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787510219/stadion_grbavica_1.jpg" },
                    { 2, "generic_sport_center_1", 2, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512809/generic_sport_center_1.jpg" },
                    { 3, "generic_sport_center_3", 3, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512806/generic_sport_center_3.jpg" },
                    { 4, "terminba/facility_photos/gnqjcwq9xkyubg6n15fr", 4, "https://res.cloudinary.com/dtzupltuu/image/upload/v1786198753/terminba/facility_photos/gnqjcwq9xkyubg6n15fr.jpg" },
                    { 5, "generic_sport_center_5", 5, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512804/generic_sport_center_5.jpg" },
                    { 6, "generic_sport_center_1", 6, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512809/generic_sport_center_1.jpg" },
                    { 7, "generic_sport_center_3", 7, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512806/generic_sport_center_3.jpg" },
                    { 8, "generic_sport_center_5", 8, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512804/generic_sport_center_5.jpg" },
                    { 9, "generic_sport_center_1", 9, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512809/generic_sport_center_1.jpg" },
                    { 10, "ramiz_salcin_2", 10, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787500716/ramiz_salcin_2.jpg" },
                    { 11, "stadion_grbavica_2", 1, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787510319/stadion_grbavica_2.jpg" },
                    { 12, "generic_sport_center_2", 2, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512807/generic_sport_center_2.jpg" },
                    { 13, "generic_sport_center_4", 3, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512808/generic_sport_center_4.jpg" },
                    { 14, "terminba/facility_photos/ve2y7t3mavtdliuhiobj", 4, "https://res.cloudinary.com/dtzupltuu/image/upload/v1786198698/terminba/facility_photos/ve2y7t3mavtdliuhiobj.jpg" },
                    { 15, "generic_sport_center_6", 5, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512804/generic_sport_center_6.jpg" },
                    { 16, "generic_sport_center_2", 6, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512807/generic_sport_center_2.jpg" },
                    { 17, "generic_sport_center_4", 7, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512808/generic_sport_center_4.jpg" },
                    { 18, "generic_sport_center_6", 8, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512804/generic_sport_center_6.jpg" },
                    { 19, "generic_sport_center_2", 9, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512807/generic_sport_center_2.jpg" },
                    { 20, "ramiz_salcin_1", 10, "https://res.cloudinary.com/dtzupltuu/image/upload/v1787500716/ramiz_salcin_1.jpg" }
                });

            migrationBuilder.InsertData(
                table: "SportCenterSports",
                columns: new[] { "AvailableSportsId", "SportCentarsId" },
                values: new object[,]
                {
                    { 1, 1 },
                    { 1, 5 },
                    { 1, 6 },
                    { 1, 7 },
                    { 1, 9 },
                    { 2, 2 },
                    { 2, 4 },
                    { 2, 6 },
                    { 2, 10 },
                    { 3, 3 },
                    { 3, 8 },
                    { 4, 2 },
                    { 4, 4 },
                    { 4, 5 },
                    { 4, 9 },
                    { 4, 10 },
                    { 5, 5 },
                    { 5, 9 }
                });

            migrationBuilder.InsertData(
                table: "WorkingHours",
                columns: new[] { "Id", "CloseingHours", "EndDay", "OpeningHours", "SportCenterId", "StartDay", "ValidFrom", "ValidTo" },
                values: new object[,]
                {
                    { 1, new TimeOnly(22, 0, 0), 5, new TimeOnly(8, 0, 0), 1, 1, new DateOnly(2025, 1, 1), null },
                    { 2, new TimeOnly(20, 0, 0), 0, new TimeOnly(9, 0, 0), 1, 6, new DateOnly(2025, 1, 1), null },
                    { 3, new TimeOnly(23, 0, 0), 0, new TimeOnly(7, 0, 0), 2, 1, new DateOnly(2025, 1, 1), null },
                    { 4, new TimeOnly(21, 0, 0), 5, new TimeOnly(6, 0, 0), 3, 1, new DateOnly(2025, 1, 1), null },
                    { 5, new TimeOnly(19, 0, 0), 0, new TimeOnly(8, 0, 0), 3, 6, new DateOnly(2025, 1, 1), null },
                    { 6, new TimeOnly(22, 0, 0), 0, new TimeOnly(8, 0, 0), 4, 1, new DateOnly(2025, 1, 1), null },
                    { 7, new TimeOnly(23, 0, 0), 0, new TimeOnly(9, 0, 0), 5, 1, new DateOnly(2025, 1, 1), null },
                    { 8, new TimeOnly(23, 0, 0), 0, new TimeOnly(8, 0, 0), 6, 1, new DateOnly(2025, 1, 1), null },
                    { 9, new TimeOnly(22, 0, 0), 0, new TimeOnly(7, 0, 0), 7, 1, new DateOnly(2025, 1, 1), null },
                    { 10, new TimeOnly(21, 0, 0), 0, new TimeOnly(8, 0, 0), 8, 1, new DateOnly(2025, 1, 1), null },
                    { 11, new TimeOnly(22, 0, 0), 0, new TimeOnly(9, 0, 0), 9, 1, new DateOnly(2025, 1, 1), null },
                    { 12, new TimeOnly(23, 59, 0), 0, new TimeOnly(6, 0, 0), 10, 1, new DateOnly(2025, 1, 1), null }
                });

            migrationBuilder.InsertData(
                table: "FacilityDynamicPrices",
                columns: new[] { "Id", "EndDay", "EndTime", "FacilityId", "PricePerHour", "StartDay", "StartTime", "ValidFrom", "ValidTo" },
                values: new object[,]
                {
                    { 1, 5, new TimeOnly(17, 0, 0), 1, 60.00m, 1, new TimeOnly(8, 0, 0), new DateOnly(2025, 1, 1), null },
                    { 2, 5, new TimeOnly(22, 0, 0), 1, 80.00m, 1, new TimeOnly(17, 0, 0), new DateOnly(2025, 1, 1), null },
                    { 3, 0, new TimeOnly(20, 0, 0), 1, 90.00m, 6, new TimeOnly(9, 0, 0), new DateOnly(2025, 1, 1), null },
                    { 4, 5, new TimeOnly(21, 0, 0), 3, 45.00m, 1, new TimeOnly(6, 0, 0), new DateOnly(2025, 1, 1), null },
                    { 5, 0, new TimeOnly(19, 0, 0), 3, 55.00m, 6, new TimeOnly(8, 0, 0), new DateOnly(2025, 1, 1), null },
                    { 6, 5, new TimeOnly(15, 0, 0), 7, 50.00m, 1, new TimeOnly(8, 0, 0), new DateOnly(2025, 1, 1), null },
                    { 7, 5, new TimeOnly(23, 0, 0), 7, 70.00m, 1, new TimeOnly(16, 0, 0), new DateOnly(2025, 1, 1), null },
                    { 8, 0, new TimeOnly(23, 0, 0), 7, 80.00m, 6, new TimeOnly(9, 0, 0), new DateOnly(2025, 1, 1), null },
                    { 9, 5, new TimeOnly(16, 0, 0), 10, 50.00m, 1, new TimeOnly(8, 0, 0), new DateOnly(2025, 1, 1), null },
                    { 10, 5, new TimeOnly(22, 0, 0), 10, 75.00m, 1, new TimeOnly(16, 0, 0), new DateOnly(2025, 1, 1), null },
                    { 11, 0, new TimeOnly(20, 0, 0), 12, 60.00m, 6, new TimeOnly(8, 0, 0), new DateOnly(2025, 1, 1), null },
                    { 12, 0, new TimeOnly(22, 0, 0), 10, 60.00m, 6, new TimeOnly(8, 0, 0), new DateOnly(2025, 1, 1), null }
                });

            migrationBuilder.InsertData(
                table: "FacilityPhotos",
                columns: new[] { "Id", "FacilityId", "PublicId", "Url" },
                values: new object[,]
                {
                    { 1, 1, "stadion_grbavica_teren_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787510460/stadion_grbavica_teren_1.jpg" },
                    { 2, 2, "generic_facility_court_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514242/generic_facility_court_1.jpg" },
                    { 3, 3, "generic_tennis_facility_court_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514594/generic_tennis_facility_court_1.jpg" },
                    { 4, 4, "generic_facility_court_3", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514248/generic_facility_court_3.jpg" },
                    { 5, 5, "terminba/facility_photos/dsleufbrkovgfqel3mui", "https://res.cloudinary.com/dtzupltuu/image/upload/v1786048421/terminba/facility_photos/dsleufbrkovgfqel3mui.jpg" },
                    { 6, 6, "terminba/facility_photos/dsleufbrkovgfqel3mui", "https://res.cloudinary.com/dtzupltuu/image/upload/v1786048421/terminba/facility_photos/dsleufbrkovgfqel3mui.jpg" },
                    { 7, 7, "generic_facility_court_5", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514238/generic_facility_court_5.jpg" },
                    { 8, 8, "generic_football_facility_court_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787515291/generic_football_facility_court_1.jpg" },
                    { 9, 9, "generic_facility_court_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514242/generic_facility_court_1.jpg" },
                    { 10, 10, "generic_football_facility_court_3", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787515289/generic_football_facility_court_3.jpg" },
                    { 11, 11, "generic_football_facility_court_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787515291/generic_football_facility_court_1.jpg" },
                    { 12, 12, "generic_tennis_facility_court_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514594/generic_tennis_facility_court_1.jpg" },
                    { 13, 13, "generic_tennis_facility_court_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514594/generic_tennis_facility_court_1.jpg" },
                    { 14, 14, "generic_tennis_facility_court_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514594/generic_tennis_facility_court_1.jpg" },
                    { 15, 15, "generic_facility_court_3", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514248/generic_facility_court_3.jpg" },
                    { 16, 16, "ramiz_salcin_sala_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787500868/ramiz_salcin_sala_1.jpg" },
                    { 17, 17, "ramiz_salcin_sala_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787500868/ramiz_salcin_sala_2.jpg" },
                    { 18, 1, "stadion_grbavica_teren_2", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787510497/stadion_grbavica_teren_2.jpg" },
                    { 19, 2, "generic_facility_court_2", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514239/generic_facility_court_2.jpg" },
                    { 20, 3, "generic_tennis_facility_court_2", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514595/generic_tennis_facility_court_2.jpg" },
                    { 21, 4, "generic_facility_court_4", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514239/generic_facility_court_4.jpg" },
                    { 22, 5, "terminba/facility_photos/mkrzxzvalq2kdz2xlfga", "https://res.cloudinary.com/dtzupltuu/image/upload/v1786048406/terminba/facility_photos/mkrzxzvalq2kdz2xlfga.jpg" },
                    { 23, 6, "terminba/facility_photos/mkrzxzvalq2kdz2xlfga", "https://res.cloudinary.com/dtzupltuu/image/upload/v1786048406/terminba/facility_photos/mkrzxzvalq2kdz2xlfga.jpg" },
                    { 24, 7, "generic_facility_court_6", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514237/generic_facility_court_6.jpg" },
                    { 25, 8, "generic_football_facility_court_2", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787515289/generic_football_facility_court_2.jpg" },
                    { 26, 9, "generic_facility_court_2", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514239/generic_facility_court_2.jpg" },
                    { 27, 10, "generic_football_facility_court_4", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787515289/generic_football_facility_court_4.jpg" },
                    { 28, 11, "generic_football_facility_court_2", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787515289/generic_football_facility_court_2.jpg" },
                    { 29, 12, "generic_tennis_facility_court_2", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514595/generic_tennis_facility_court_2.jpg" },
                    { 30, 13, "generic_tennis_facility_court_2", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514595/generic_tennis_facility_court_2.jpg" },
                    { 31, 14, "generic_tennis_facility_court_2", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514595/generic_tennis_facility_court_2.jpg" },
                    { 32, 15, "generic_facility_court_4", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514239/generic_facility_court_4.jpg" },
                    { 33, 16, "ramiz_salcin_sala_2", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787500869/ramiz_salcin_sala_2.jpg" },
                    { 34, 17, "ramiz_salcin_sala_2", "hhttps://res.cloudinary.com/dtzupltuu/image/upload/v1787500869/ramiz_salcin_sala_2.jpg" },
                    { 35, 1, "stadion_grbavica_teren_3", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787510604/stadion_grbavica_teren_3.jpg" },
                    { 36, 2, "generic_facility_court_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514242/generic_facility_court_1.jpg" },
                    { 37, 3, "generic_tennis_facility_court_1", "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514594/generic_tennis_facility_court_1.jpg" }
                });

            migrationBuilder.InsertData(
                table: "FacilitySports",
                columns: new[] { "AvailableSportsId", "FacilitiesId" },
                values: new object[,]
                {
                    { 1, 1 },
                    { 1, 7 },
                    { 1, 8 },
                    { 1, 10 },
                    { 1, 11 },
                    { 1, 15 },
                    { 2, 2 },
                    { 2, 5 },
                    { 2, 9 },
                    { 2, 16 },
                    { 2, 17 },
                    { 3, 3 },
                    { 3, 12 },
                    { 3, 13 },
                    { 3, 14 },
                    { 4, 4 },
                    { 4, 6 },
                    { 4, 7 },
                    { 4, 15 },
                    { 4, 16 },
                    { 5, 7 },
                    { 5, 15 }
                });

            migrationBuilder.InsertData(
                table: "Reservations",
                columns: new[] { "Id", "CanceledAt", "CancellationDeadline", "ChosenSportId", "CompletedAt", "EndTime", "FacilityId", "PaymentMethod", "Price", "ReservationDate", "StartTime", "Status", "UserId" },
                values: new object[,]
                {
                    { 1, null, null, 1, null, new TimeOnly(19, 30, 0), 1, null, 80.00m, new DateOnly(2026, 1, 20), new TimeOnly(18, 0, 0), "CompletedReservationState", 2 },
                    { 2, null, null, 2, null, new TimeOnly(20, 0, 0), 2, null, 50.00m, new DateOnly(2026, 2, 25), new TimeOnly(19, 0, 0), "CompletedReservationState", 3 },
                    { 3, null, null, 3, null, new TimeOnly(11, 0, 0), 3, null, 45.00m, new DateOnly(2026, 3, 15), new TimeOnly(10, 0, 0), "CompletedReservationState", 4 },
                    { 4, null, null, 1, null, new TimeOnly(21, 30, 0), 1, null, 80.00m, new DateOnly(2026, 4, 10), new TimeOnly(20, 0, 0), "CompletedReservationState", 2 },
                    { 5, null, null, 4, null, new TimeOnly(17, 30, 0), 4, null, 40.00m, new DateOnly(2026, 5, 5), new TimeOnly(16, 0, 0), "CompletedReservationState", 3 },
                    { 6, null, null, 2, null, new TimeOnly(19, 0, 0), 5, null, 30.00m, new DateOnly(2026, 6, 15), new TimeOnly(18, 0, 0), "CompletedReservationState", 5 },
                    { 7, null, null, 4, null, new TimeOnly(18, 0, 0), 6, null, 20.00m, new DateOnly(2026, 7, 20), new TimeOnly(17, 0, 0), "CompletedReservationState", 6 },
                    { 8, null, null, 5, null, new TimeOnly(21, 30, 0), 7, null, 70.00m, new DateOnly(2026, 8, 10), new TimeOnly(20, 0, 0), "CompletedReservationState", 7 },
                    { 9, null, null, 1, null, new TimeOnly(16, 30, 0), 8, null, 80.00m, new DateOnly(2026, 1, 20), new TimeOnly(15, 0, 0), "CompletedReservationState", 8 },
                    { 10, null, null, 2, null, new TimeOnly(19, 0, 0), 9, null, 40.00m, new DateOnly(2026, 2, 25), new TimeOnly(18, 0, 0), "CompletedReservationState", 2 },
                    { 11, null, null, 1, null, new TimeOnly(21, 30, 0), 10, null, 60.00m, new DateOnly(2026, 3, 15), new TimeOnly(20, 0, 0), "CompletedReservationState", 3 },
                    { 12, null, null, 1, null, new TimeOnly(20, 30, 0), 11, null, 40.00m, new DateOnly(2026, 4, 10), new TimeOnly(19, 0, 0), "CompletedReservationState", 4 },
                    { 13, null, null, 3, null, new TimeOnly(11, 0, 0), 12, null, 50.00m, new DateOnly(2026, 8, 28), new TimeOnly(10, 0, 0), "ActiveReservationState", 5 },
                    { 14, null, null, 3, null, new TimeOnly(12, 0, 0), 13, null, 30.00m, new DateOnly(2026, 9, 5), new TimeOnly(11, 0, 0), "ActiveReservationState", 6 },
                    { 15, null, null, 3, null, new TimeOnly(13, 0, 0), 14, null, 30.00m, new DateOnly(2026, 9, 5), new TimeOnly(12, 0, 0), "ActiveReservationState", 2 },
                    { 16, null, null, 5, null, new TimeOnly(19, 30, 0), 15, null, 45.00m, new DateOnly(2026, 10, 10), new TimeOnly(18, 0, 0), "ActiveReservationState", 7 },
                    { 17, null, null, 2, null, new TimeOnly(20, 0, 0), 16, null, 100.00m, new DateOnly(2026, 10, 10), new TimeOnly(19, 0, 0), "ActiveReservationState", 8 },
                    { 18, null, null, 2, null, new TimeOnly(21, 0, 0), 17, null, 70.00m, new DateOnly(2026, 11, 20), new TimeOnly(20, 0, 0), "ActiveReservationState", 9 },
                    { 19, null, null, 1, null, new TimeOnly(18, 30, 0), 1, null, 80.00m, new DateOnly(2026, 11, 20), new TimeOnly(17, 0, 0), "ActiveReservationState", 10 },
                    { 20, null, null, 2, null, new TimeOnly(19, 0, 0), 2, null, 50.00m, new DateOnly(2026, 12, 15), new TimeOnly(18, 0, 0), "ActiveReservationState", 11 },
                    { 21, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 9, 1), new TimeOnly(20, 0, 0), "ActiveReservationState", 2 },
                    { 22, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 9, 8), new TimeOnly(20, 0, 0), "ActiveReservationState", 2 },
                    { 23, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 9, 15), new TimeOnly(20, 0, 0), "ActiveReservationState", 2 },
                    { 24, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 9, 22), new TimeOnly(20, 0, 0), "ActiveReservationState", 2 },
                    { 25, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 9, 29), new TimeOnly(20, 0, 0), "ActiveReservationState", 2 },
                    { 26, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 10, 6), new TimeOnly(20, 0, 0), "ActiveReservationState", 2 },
                    { 27, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 10, 13), new TimeOnly(20, 0, 0), "ActiveReservationState", 2 },
                    { 28, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 10, 20), new TimeOnly(20, 0, 0), "ActiveReservationState", 2 },
                    { 29, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 10, 27), new TimeOnly(20, 0, 0), "ActiveReservationState", 2 },
                    { 30, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 11, 3), new TimeOnly(20, 0, 0), "ActiveReservationState", 2 },
                    { 31, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 6, 1), new TimeOnly(20, 0, 0), "CompletedReservationState", 2 },
                    { 32, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 6, 8), new TimeOnly(20, 0, 0), "CompletedReservationState", 2 },
                    { 33, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 6, 15), new TimeOnly(20, 0, 0), "CompletedReservationState", 2 },
                    { 34, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 6, 22), new TimeOnly(20, 0, 0), "CompletedReservationState", 2 },
                    { 35, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 6, 29), new TimeOnly(20, 0, 0), "CompletedReservationState", 2 },
                    { 36, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 7, 6), new TimeOnly(20, 0, 0), "CompletedReservationState", 2 },
                    { 37, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 7, 13), new TimeOnly(20, 0, 0), "CompletedReservationState", 2 },
                    { 38, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 7, 20), new TimeOnly(20, 0, 0), "CompletedReservationState", 2 },
                    { 39, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 7, 27), new TimeOnly(20, 0, 0), "CompletedReservationState", 2 },
                    { 40, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 8, 3), new TimeOnly(20, 0, 0), "CompletedReservationState", 2 },
                    { 41, null, null, 2, null, new TimeOnly(12, 0, 0), 5, null, 30.00m, new DateOnly(2026, 9, 1), new TimeOnly(11, 0, 0), "ActiveReservationState", 3 },
                    { 42, null, null, 2, null, new TimeOnly(12, 0, 0), 5, null, 30.00m, new DateOnly(2026, 9, 8), new TimeOnly(11, 0, 0), "ActiveReservationState", 3 },
                    { 43, null, null, 2, null, new TimeOnly(12, 0, 0), 5, null, 30.00m, new DateOnly(2026, 9, 15), new TimeOnly(11, 0, 0), "ActiveReservationState", 3 },
                    { 44, null, null, 2, null, new TimeOnly(12, 0, 0), 5, null, 30.00m, new DateOnly(2026, 6, 1), new TimeOnly(11, 0, 0), "CompletedReservationState", 3 },
                    { 45, null, null, 2, null, new TimeOnly(12, 0, 0), 5, null, 30.00m, new DateOnly(2026, 6, 8), new TimeOnly(11, 0, 0), "CompletedReservationState", 3 },
                    { 46, null, null, 2, null, new TimeOnly(12, 0, 0), 5, null, 30.00m, new DateOnly(2026, 6, 15), new TimeOnly(11, 0, 0), "CompletedReservationState", 3 },
                    { 47, null, null, 1, null, new TimeOnly(18, 30, 0), 1, null, 80.00m, new DateOnly(2026, 9, 17), new TimeOnly(17, 0, 0), "ActiveReservationState", 2 },
                    { 48, null, null, 1, null, new TimeOnly(19, 30, 0), 1, null, 90.00m, new DateOnly(2026, 9, 19), new TimeOnly(18, 0, 0), "ActiveReservationState", 2 },
                    { 49, null, null, 2, null, new TimeOnly(9, 0, 0), 5, null, 30.00m, new DateOnly(2026, 7, 2), new TimeOnly(8, 0, 0), "CompletedReservationState", 3 },
                    { 50, null, null, 2, null, new TimeOnly(13, 0, 0), 5, null, 30.00m, new DateOnly(2026, 7, 9), new TimeOnly(12, 0, 0), "CompletedReservationState", 4 },
                    { 51, null, null, 2, null, new TimeOnly(20, 0, 0), 5, null, 30.00m, new DateOnly(2026, 7, 21), new TimeOnly(19, 0, 0), "CompletedReservationState", 5 },
                    { 52, null, null, 2, null, new TimeOnly(11, 0, 0), 5, null, 30.00m, new DateOnly(2026, 8, 4), new TimeOnly(10, 0, 0), "CompletedReservationState", 6 },
                    { 53, null, null, 2, null, new TimeOnly(16, 0, 0), 5, null, 30.00m, new DateOnly(2026, 8, 13), new TimeOnly(15, 0, 0), "CompletedReservationState", 7 },
                    { 54, null, null, 2, null, new TimeOnly(21, 0, 0), 5, null, 30.00m, new DateOnly(2026, 8, 25), new TimeOnly(20, 0, 0), "CompletedReservationState", 8 },
                    { 55, null, null, 2, null, new TimeOnly(10, 0, 0), 5, null, 30.00m, new DateOnly(2026, 9, 3), new TimeOnly(9, 0, 0), "ActiveReservationState", 9 },
                    { 56, null, null, 2, null, new TimeOnly(15, 0, 0), 5, null, 30.00m, new DateOnly(2026, 9, 15), new TimeOnly(14, 0, 0), "ActiveReservationState", 10 },
                    { 57, null, null, 2, null, new TimeOnly(19, 0, 0), 5, null, 30.00m, new DateOnly(2026, 9, 29), new TimeOnly(18, 0, 0), "ActiveReservationState", 11 },
                    { 58, null, null, 4, null, new TimeOnly(10, 0, 0), 6, null, 20.00m, new DateOnly(2026, 7, 7), new TimeOnly(9, 0, 0), "CompletedReservationState", 4 },
                    { 59, null, null, 4, null, new TimeOnly(14, 0, 0), 6, null, 20.00m, new DateOnly(2026, 7, 16), new TimeOnly(13, 0, 0), "CompletedReservationState", 5 },
                    { 60, null, null, 4, null, new TimeOnly(19, 0, 0), 6, null, 20.00m, new DateOnly(2026, 7, 28), new TimeOnly(18, 0, 0), "CompletedReservationState", 6 },
                    { 61, null, null, 4, null, new TimeOnly(9, 0, 0), 6, null, 20.00m, new DateOnly(2026, 8, 6), new TimeOnly(8, 0, 0), "CompletedReservationState", 7 },
                    { 62, null, null, 4, null, new TimeOnly(12, 0, 0), 6, null, 20.00m, new DateOnly(2026, 8, 18), new TimeOnly(11, 0, 0), "CompletedReservationState", 8 },
                    { 63, null, null, 4, null, new TimeOnly(17, 0, 0), 6, null, 20.00m, new DateOnly(2026, 8, 27), new TimeOnly(16, 0, 0), "ActiveReservationState", 9 },
                    { 64, null, null, 4, null, new TimeOnly(11, 0, 0), 6, null, 20.00m, new DateOnly(2026, 9, 8), new TimeOnly(10, 0, 0), "ActiveReservationState", 10 },
                    { 65, null, null, 4, null, new TimeOnly(16, 0, 0), 6, null, 20.00m, new DateOnly(2026, 9, 17), new TimeOnly(15, 0, 0), "ActiveReservationState", 11 },
                    { 66, null, null, 4, null, new TimeOnly(21, 0, 0), 6, null, 20.00m, new DateOnly(2026, 9, 24), new TimeOnly(20, 0, 0), "ActiveReservationState", 3 }
                });

            migrationBuilder.InsertData(
                table: "CancelationNotifications",
                columns: new[] { "Id", "DateCancelled", "FacilityName", "IsSeen", "PostOwnerId", "RequesterName", "ReservationId" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 5, 26, 10, 0, 0, 0, DateTimeKind.Utc), "Basketball Court 1", true, 2, "User 4", 31 },
                    { 2, new DateTime(2026, 6, 16, 10, 0, 0, 0, DateTimeKind.Utc), "Basketball Court 1", false, 2, "User 3", 34 }
                });

            migrationBuilder.InsertData(
                table: "FacilityReviews",
                columns: new[] { "Id", "Comment", "FacilityId", "RatingDate", "RatingNumber", "ReservationId", "UserId" },
                values: new object[,]
                {
                    { 1, "Excellent facility, well maintained", 1, new DateOnly(2026, 1, 21), 5, 1, 2 },
                    { 2, "Great court, good lighting", 2, new DateOnly(2026, 2, 26), 4, 2, 3 },
                    { 3, "Perfect tennis court", 3, new DateOnly(2026, 3, 16), 5, 3, 4 },
                    { 4, "Nice court", 1, new DateOnly(2026, 4, 11), 4, 4, 2 },
                    { 5, "Could be better maintained", 4, new DateOnly(2026, 5, 6), 3, 5, 3 },
                    { 6, "Awesome court", 5, new DateOnly(2026, 6, 16), 5, 6, 5 },
                    { 7, "Pretty solid", 6, new DateOnly(2026, 7, 21), 4, 7, 6 },
                    { 8, "Amazing handball experience", 7, new DateOnly(2026, 8, 11), 5, 8, 7 },
                    { 9, "Good overall", 8, new DateOnly(2026, 1, 22), 4, 9, 8 },
                    { 10, "Loved it!", 9, new DateOnly(2026, 2, 27), 5, 10, 2 },
                    { 11, "Excellent basketball court and a great playing experience.", 5, new DateOnly(2026, 6, 16), 5, 33, 2 },
                    { 12, "The court was fine overall, but the changing area could be improved.", 5, new DateOnly(2026, 6, 23), 3, 34, 2 }
                });

            migrationBuilder.InsertData(
                table: "Posts",
                columns: new[] { "Id", "NumberOfPlayersFound", "NumberOfPlayersWanted", "PostState", "ReservationId", "SkillLevel", "Text" },
                values: new object[,]
                {
                    { 1, 1, 3, "FinishedPostState", 1, "Medium", "Looking for players for a friendly match" },
                    { 2, 0, 2, "FinishedPostState", 2, "Beginner", "Need players for basketball game" },
                    { 3, 1, 1, "FinishedPostState", 3, "Advanced", "Looking for a tennis partner" },
                    { 4, 2, 4, "FinishedPostState", 4, "Medium", "Football match - need more players" },
                    { 5, 0, 2, "FinishedPostState", 5, "Medium", "Volleyball players needed" },
                    { 6, 2, 5, "FinishedPostState", 6, "Beginner", "Casual basketball game" },
                    { 7, 1, 2, "PlayerSearchPostState", 21, "Medium", "Looking for players for a friendly match" },
                    { 8, 2, 2, "PlayerFoundPostState", 22, "Medium", "Looking for players for a friendly match" },
                    { 9, 1, 2, "PlayerSearchPostState", 23, "Medium", "Looking for players for a friendly match" },
                    { 10, 2, 2, "PlayerFoundPostState", 24, "Medium", "Looking for players for a friendly match" },
                    { 11, 1, 2, "PlayerSearchPostState", 25, "Medium", "Looking for players for a friendly match" },
                    { 12, 1, 2, "FinishedPostState", 31, "Medium", "Looking for players for a friendly match" },
                    { 13, 2, 2, "FinishedPostState", 32, "Medium", "Looking for players for a friendly match" },
                    { 14, 1, 2, "FinishedPostState", 33, "Medium", "Looking for players for a friendly match" },
                    { 15, 2, 2, "FinishedPostState", 34, "Medium", "Looking for players for a friendly match" },
                    { 16, 1, 2, "FinishedPostState", 35, "Medium", "Looking for players for a friendly match" },
                    { 17, 0, 3, "PlayerSearchPostState", 41, "Beginner", "Looking for players for a casual basketball game" },
                    { 18, 2, 3, "PlayerSearchPostState", 42, "Medium", "Need one more player for a basketball game" },
                    { 19, 3, 3, "PlayerFoundPostState", 43, "Medium", "Basketball game is full, see you on the court" }
                });

            migrationBuilder.InsertData(
                table: "UserReviews",
                columns: new[] { "Id", "Comment", "RatingDate", "RatingNumber", "ReservationId", "ReviewedId", "ReviewerId" },
                values: new object[,]
                {
                    { 1, "Great host and a very fair player.", new DateOnly(2026, 1, 21), 5, 1, 10, 2 },
                    { 2, "Excellent sportsmanship and a great match.", new DateOnly(2026, 3, 16), 5, 3, 2, 4 },
                    { 3, "Reliable player and well organized game.", new DateOnly(2026, 4, 11), 4, 4, 3, 2 },
                    { 4, "Friendly host. I would gladly play again.", new DateOnly(2026, 4, 11), 5, 4, 6, 2 },
                    { 5, "Average player", new DateOnly(2026, 5, 6), 3, 5, 7, 3 },
                    { 6, "Fun to play with", new DateOnly(2026, 6, 16), 5, 6, 6, 5 },
                    { 7, "Decent skills", new DateOnly(2026, 7, 21), 4, 7, 8, 6 },
                    { 8, "Great attitude", new DateOnly(2026, 8, 11), 5, 8, 9, 7 },
                    { 9, "Good player", new DateOnly(2026, 1, 22), 4, 9, 10, 8 },
                    { 10, "Would play again", new DateOnly(2026, 2, 27), 5, 10, 5, 2 }
                });

            migrationBuilder.InsertData(
                table: "PlayRequests",
                columns: new[] { "Id", "CanceledAt", "CanceledById", "DateOfRequest", "DateOfResponse", "IsSeenByOwner", "IsSeenByRequester", "PlayRequestState", "PostId", "Reason", "RequestText", "RequesterId", "RespondedAt", "RespondedById" },
                values: new object[,]
                {
                    { 1, null, null, new DateTime(2026, 1, 11, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 1, 12, 10, 0, 0, 0, DateTimeKind.Utc), false, false, "AcceptedPlayRequestState", 1, null, "I'd like to join your game", 10, null, null },
                    { 2, null, null, new DateTime(2026, 2, 20, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 2, 21, 10, 0, 0, 0, DateTimeKind.Utc), false, false, "RejectedPlayRequestState", 2, null, "Can I join?", 11, null, null },
                    { 3, null, null, new DateTime(2026, 3, 10, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 3, 12, 10, 0, 0, 0, DateTimeKind.Utc), false, false, "AcceptedPlayRequestState", 3, null, "I'm available for tennis", 2, null, null },
                    { 4, null, null, new DateTime(2026, 4, 1, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 4, 2, 10, 0, 0, 0, DateTimeKind.Utc), false, false, "AcceptedPlayRequestState", 4, null, "Count me in for football", 3, null, null },
                    { 5, null, null, new DateTime(2026, 4, 3, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 4, 5, 10, 0, 0, 0, DateTimeKind.Utc), false, false, "AcceptedPlayRequestState", 4, null, "I want to play", 6, null, null },
                    { 6, null, null, new DateTime(2026, 1, 13, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 1, 14, 18, 0, 0, 0, DateTimeKind.Utc), false, false, "AcceptedPlayRequestState", 1, null, "Count me in!", 3, null, null },
                    { 7, null, null, new DateTime(2026, 1, 13, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 1, 14, 18, 0, 0, 0, DateTimeKind.Utc), false, false, "RejectedPlayRequestState", 1, null, "Count me in!", 4, null, null },
                    { 8, null, null, new DateTime(2026, 1, 13, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 1, 14, 18, 0, 0, 0, DateTimeKind.Utc), false, false, "CanceledPlayRequestState", 1, null, "Count me in!", 5, null, null },
                    { 9, null, null, new DateTime(2026, 1, 13, 18, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 1, 14, 18, 0, 0, 0, DateTimeKind.Utc), false, false, "ExpiredPlayRequestState", 1, null, "Count me in!", 6, null, null },
                    { 10, null, null, new DateTime(2026, 8, 25, 20, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 8, 26, 20, 0, 0, 0, DateTimeKind.Utc), false, false, "RejectedPlayRequestState", 7, null, "Count me in!", 3, null, null },
                    { 11, null, null, new DateTime(2026, 4, 3, 20, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 4, 4, 20, 0, 0, 0, DateTimeKind.Utc), false, false, "CanceledPlayRequestState", 4, null, "Count me in!", 4, null, null },
                    { 12, null, null, new DateTime(2026, 4, 3, 20, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 4, 4, 20, 0, 0, 0, DateTimeKind.Utc), false, false, "AcceptedPlayRequestState", 4, null, "Count me in!", 5, null, null }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "CancelationNotifications",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "CancelationNotifications",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "FacilityDynamicPrices",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "FacilityDynamicPrices",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "FacilityDynamicPrices",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "FacilityDynamicPrices",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "FacilityDynamicPrices",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "FacilityDynamicPrices",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "FacilityDynamicPrices",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "FacilityDynamicPrices",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "FacilityDynamicPrices",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "FacilityDynamicPrices",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "FacilityDynamicPrices",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "FacilityDynamicPrices",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 26);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 27);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 28);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 29);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 30);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 31);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 32);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 33);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 34);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 35);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 36);

            migrationBuilder.DeleteData(
                table: "FacilityPhotos",
                keyColumn: "Id",
                keyValue: 37);

            migrationBuilder.DeleteData(
                table: "FacilityReviews",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "FacilityReviews",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "FacilityReviews",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "FacilityReviews",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "FacilityReviews",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "FacilityReviews",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "FacilityReviews",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "FacilityReviews",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "FacilityReviews",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "FacilityReviews",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "FacilityReviews",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "FacilityReviews",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 1, 1 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 1, 7 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 1, 8 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 1, 10 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 1, 11 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 1, 15 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 2, 2 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 2, 5 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 2, 9 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 2, 16 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 2, 17 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 3, 3 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 3, 12 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 3, 13 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 3, 14 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 4, 4 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 4, 6 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 4, 7 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 4, 15 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 4, 16 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 5, 7 });

            migrationBuilder.DeleteData(
                table: "FacilitySports",
                keyColumns: new[] { "AvailableSportsId", "FacilitiesId" },
                keyValues: new object[] { 5, 15 });

            migrationBuilder.DeleteData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "PlayRequests",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 26);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 27);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 28);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 29);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 30);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 36);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 37);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 38);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 39);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 40);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 44);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 45);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 46);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 47);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 48);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 49);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 50);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 51);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 52);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 53);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 54);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 55);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 56);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 57);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 58);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 59);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 60);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 61);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 62);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 63);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 64);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 65);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 66);

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 1, 1 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 1, 2 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 1, 3 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 1, 4 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 1, 5 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 1, 6 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 1, 7 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 1, 8 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 1, 9 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 1, 10 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 2, 1 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 2, 2 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 2, 3 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 2, 4 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 2, 5 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 2, 6 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 2, 8 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 2, 10 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 3, 1 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 3, 2 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 3, 3 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 3, 4 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 3, 5 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 3, 6 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 3, 9 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 3, 10 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 4, 1 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 4, 2 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 4, 3 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 4, 5 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 4, 8 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 4, 10 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 5, 1 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 5, 2 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 5, 4 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 5, 9 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 5, 10 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 6, 1 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 6, 2 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 6, 3 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 6, 4 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 6, 5 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 6, 7 });

            migrationBuilder.DeleteData(
                table: "SportCenterAmenities",
                keyColumns: new[] { "AvailableAmenitiesId", "SportCentarsId" },
                keyValues: new object[] { 6, 10 });

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "SportCenterPhotos",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 1, 1 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 1, 5 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 1, 6 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 1, 7 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 1, 9 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 2, 2 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 2, 4 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 2, 6 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 2, 10 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 3, 3 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 3, 8 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 4, 2 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 4, 4 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 4, 5 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 4, 9 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 4, 10 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 5, 5 });

            migrationBuilder.DeleteData(
                table: "SportCenterSports",
                keyColumns: new[] { "AvailableSportsId", "SportCentarsId" },
                keyValues: new object[] { 5, 9 });

            migrationBuilder.DeleteData(
                table: "UserReviews",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "UserReviews",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "UserReviews",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "UserReviews",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "UserReviews",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "UserReviews",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "UserReviews",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "UserReviews",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "UserReviews",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "UserReviews",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "WorkingHours",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "WorkingHours",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "WorkingHours",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "WorkingHours",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "WorkingHours",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "WorkingHours",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "WorkingHours",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "WorkingHours",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "WorkingHours",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "WorkingHours",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "WorkingHours",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "WorkingHours",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Amenity",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Amenity",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Amenity",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Amenity",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Amenity",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Amenity",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Posts",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 31);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 32);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 33);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 34);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 35);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 41);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 42);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 43);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Sports",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Sports",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "TurfTypes",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "TurfTypes",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Facilities",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Sports",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Sports",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Sports",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "SportCenters",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "TurfTypes",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "TurfTypes",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "TurfTypes",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2);
        }
    }
}
