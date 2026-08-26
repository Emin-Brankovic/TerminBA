using Microsoft.EntityFrameworkCore;
using TerminBA.Services.Helpers;
using TerminBA.Services.PlayRequestStateMachine;
using TerminBA.Services.PostStateMachine;
using TerminBA.Services.ReservationStateMachine;

namespace TerminBA.Services.Database
{
    public partial class TerminBaContext : DbContext
    {
        string plainPassword = "password";

        private void CreateSeed(ModelBuilder modelBuilder)
        {
            SeedRoles(modelBuilder);
            SeedCities(modelBuilder);
            SeedSports(modelBuilder);
            SeedTurfTypes(modelBuilder);
            SeedAmenities(modelBuilder);
            SeedUsers(modelBuilder);
            SeedSportCenters(modelBuilder);
            SeedSportCenterSports(modelBuilder);
            SeedSportCenterAmenities(modelBuilder);
            SeedWorkingHours(modelBuilder);
            SeedFacilities(modelBuilder);
            SeedFacilitySports(modelBuilder);
            SeedFacilityDynamicPrices(modelBuilder);
            SeedReservations(modelBuilder);
            SeedPosts(modelBuilder);
            SeedPlayRequests(modelBuilder);
            SeedCancelationNotifications(modelBuilder);
            SeedFacilityReviews(modelBuilder);
            SeedUserReviews(modelBuilder);
            SeedSportCenterPhotos(modelBuilder);
            SeedFacilityPhotos(modelBuilder);
        }

        private static void SeedRoles(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Role>().HasData(
                new Role { Id = 1, Name = "User",             RoleDescription = "Regular user who can make reservations" },
                new Role { Id = 2, Name = "Sport center",     RoleDescription = "Owner of a sport center" },
                new Role { Id = 3, Name = "Administrator",    RoleDescription = "Administrator with full system access" }
            );
        }

        private static void SeedCities(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<City>().HasData(
                new City { Id = 1, Name = "Sarajevo"  },
                new City { Id = 2, Name = "Banja Luka" },
                new City { Id = 3, Name = "Tuzla"     },
                new City { Id = 4, Name = "Zenica"    },
                new City { Id = 5, Name = "Mostar"    },
                new City { Id = 6, Name = "Konjic"    },
                new City { Id = 7, Name = "Travnik"   },
                new City { Id = 8, Name = "Doboj"     }
            );
        }

        private static void SeedSports(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Sport>().HasData(
                new Sport { Id = 1, Name = "Football"     },
                new Sport { Id = 2, Name = "Basketball"   },
                new Sport { Id = 3, Name = "Tennis"       },
                new Sport { Id = 4, Name = "Volleyball"   },
                new Sport { Id = 5, Name = "Handball"     }
            );
        }

        private static void SeedTurfTypes(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<TurfType>().HasData(
                new TurfType { Id = 1, Name = "Natural Grass"    },
                new TurfType { Id = 2, Name = "Artificial Grass" },
                new TurfType { Id = 3, Name = "Hardwood"         },
                new TurfType { Id = 4, Name = "Clay"             },
                new TurfType { Id = 5, Name = "Tartan"           }
            );
        }

        private static void SeedAmenities(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Amenity>().HasData(
                new Amenity { Id = 1, Name = "Parking"          },
                new Amenity { Id = 2, Name = "Locker Room"      },
                new Amenity { Id = 3, Name = "Shower"           },
                new Amenity { Id = 4, Name = "Cafeteria"        },
                new Amenity { Id = 5, Name = "WiFi"             },
                new Amenity { Id = 6, Name = "First Aid"        }
            );
        }

        private void SeedUsers(ModelBuilder modelBuilder)
        {
            var birthDate = new DateOnly(1999, 1, 1);
            var d1 = new DateTime(2025, 12, 5, 10, 0, 0, DateTimeKind.Utc);
            var d2 = new DateTime(2026, 1, 15, 12, 0, 0, DateTimeKind.Utc);
            var d3 = new DateTime(2026, 2, 20, 14, 0, 0, DateTimeKind.Utc);
            var d4 = new DateTime(2026, 3, 10, 9, 0, 0, DateTimeKind.Utc);
            var d5 = new DateTime(2026, 4, 5, 11, 0, 0, DateTimeKind.Utc);
            var d6 = new DateTime(2026, 5, 25, 16, 0, 0, DateTimeKind.Utc);
            var d7 = new DateTime(2026, 6, 1, 10, 0, 0, DateTimeKind.Utc);
            var d8 = new DateTime(2026, 7, 12, 13, 0, 0, DateTimeKind.Utc);
            var d9 = new DateTime(2026, 8, 2, 15, 0, 0, DateTimeKind.Utc);
            var d10 = new DateTime(2026, 8, 10, 8, 0, 0, DateTimeKind.Utc);
            var d11 = new DateTime(2026, 8, 20, 18, 0, 0, DateTimeKind.Utc);

            modelBuilder.Entity<User>().HasData(
                MakeUser(1,  "Admin",   "Admin",    "admin@gmail.com",  "+38761123456", roleId: 3, cityId: 1, birthDate, d1, "admin"),
                MakeUser(2,  "Test",     "User", "emin.brankovic@edu.fit.ba",   "+38761123456", roleId: 1, cityId: 1, birthDate, d2, "user"),
                MakeUser(3,  "Jasna",    "Kovacevic", "jasna.kovacevic@example.com",  "+38761123457", roleId: 1, cityId: 2, birthDate, d3),
                MakeUser(4,  "Nermin",   "Delic",     "nermin.delic@example.com",     "+38761123458", roleId: 1, cityId: 3, birthDate, d4),
                MakeUser(5,  "Ivana",    "Juric",     "ivana.juric@example.com",      "+38761123459", roleId: 1, cityId: 1, birthDate, d5),
                MakeUser(6,  "Adnan",    "Begovic",   "adnan.begovic@example.com",    "+38761123460", roleId: 1, cityId: 2, birthDate, d6),
                MakeUser(7,  "Lejla",    "Halilovic", "lejla.halilovic@example.com",  "+38761123461", roleId: 1, cityId: 3, birthDate, d7),
                MakeUser(8,  "Haris",    "Mujanovic", "haris.mujanovic@example.com",  "+38761123462", roleId: 1, cityId: 1, birthDate, d8),
                MakeUser(9,  "Selma",    "Djuric",    "selma.djuric@example.com",     "+38761123463", roleId: 1, cityId: 2, birthDate, d9),
                MakeUser(10, "Emina",    "Hasanovic", "emina.hasanovic@example.com",  "+38761123464", roleId: 1, cityId: 3, birthDate, d10),
                MakeUser(11, "Tarik",    "Vukovic",   "tarik.vukovic@example.com",    "+38761123465", roleId: 1, cityId: 1, birthDate, d11)
            );
        }

        private void SeedSportCenters(ModelBuilder modelBuilder)
        {
            var createdAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc);

            modelBuilder.Entity<SportCenter>().HasData(
                MakeSportCenter(
                    1, "Stadion Grbavica", "Grbavica 1, Sarajevo", "+38761123470",
                    roleId: 2, cityId: 1, isEquipmentProvided: true,
                    "Premier football stadium with modern facilities", createdAt,
                    latitude: 43.846670m, longitude: 18.387220m),

                MakeSportCenter(
                    2, "Basketball Arena", "Centar, Banja Luka", "+38761123471",
                    roleId: 2, cityId: 2, isEquipmentProvided: true,
                    "Professional basketball court with indoor facilities", createdAt,
                    latitude: 44.772181m, longitude: 17.191000m),

                MakeSportCenter(
                    3, "Tennis Club Tuzla", "Slatina, Tuzla", "+38761123472",
                    roleId: 2, cityId: 3, isEquipmentProvided: false,
                    "Outdoor tennis courts with clay and hard court surfaces", createdAt,
                    latitude: 44.541390m, longitude: 18.665000m),

                MakeSportCenter(
                    4, "Skenderija", "Terezija bb, Sarajevo", "+38761123473",
                    roleId: 2, cityId: 1, isEquipmentProvided: true,
                    "Huge indoor complex in the heart of Sarajevo", createdAt,
                    latitude: 43.8554721469m, longitude: 18.4143950288m),

                MakeSportCenter(
                    5, "Mostar Indoor Arena", "Zalik, Mostar", "+38761123474",
                    roleId: 2, cityId: 5, isEquipmentProvided: true,
                    "Great indoor arena for various sports", createdAt,
                    latitude: 43.357300m, longitude: 17.819800m),

                MakeSportCenter(
                    6, "Zenica Sports Center", "Kamberovica polje, Zenica", "+38761123475",
                    roleId: 2, cityId: 4, isEquipmentProvided: true,
                    "Main sports complex in Zenica", createdAt,
                    latitude: 44.203823m, longitude: 17.910900m),

                MakeSportCenter(
                    7, "Doboj Football Academy", "Usora, Doboj", "+38761123476",
                    roleId: 2, cityId: 8, isEquipmentProvided: true,
                    "Top football academy with multiple fields", createdAt,
                    latitude: 44.736000m, longitude: 18.087900m),

                MakeSportCenter(
                    8, "Konjic Tennis Complex", "Koviljuse, Konjic", "+38761123477",
                    roleId: 2, cityId: 6, isEquipmentProvided: false,
                    "Large complex of professional tennis courts", createdAt,
                    latitude: 43.623000m, longitude: 17.952000m),

                MakeSportCenter(
                    9, "Travnik Indoor Arena", "Pecani, Travnik", "+38761123478",
                    roleId: 2, cityId: 7, isEquipmentProvided: true,
                    "Modern indoor arena for multiple sports", createdAt,
                    latitude: 44.219500m, longitude: 17.670900m),

                MakeSportCenter(
                    10, "Ramiz Salcin", "Semira Frašte 21, Sarajevo", "+38761123479",
                    roleId: 2, cityId: 1, isEquipmentProvided: true,
                    "Large sports complex with multi-purpose courts", createdAt,
                    latitude: 43.849570m, longitude: 18.360830m)
            );
        }

        // Join table: SportCenterSports (SportSportCenter) — columns: AvailableSportsId, SportCentarsId
        private static void SeedSportCenterSports(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity("SportSportCenter").HasData(
                new { AvailableSportsId = 1, SportCentarsId = 1 },
                new { AvailableSportsId = 2, SportCentarsId = 2 },
                new { AvailableSportsId = 4, SportCentarsId = 2 },
                new { AvailableSportsId = 3, SportCentarsId = 3 },
                new { AvailableSportsId = 2, SportCentarsId = 4 },
                new { AvailableSportsId = 4, SportCentarsId = 4 },
                new { AvailableSportsId = 5, SportCentarsId = 5 },
                new { AvailableSportsId = 1, SportCentarsId = 5 },
                new { AvailableSportsId = 4, SportCentarsId = 5 },
                new { AvailableSportsId = 1, SportCentarsId = 6 },
                new { AvailableSportsId = 2, SportCentarsId = 6 },
                new { AvailableSportsId = 1, SportCentarsId = 7 },
                new { AvailableSportsId = 3, SportCentarsId = 8 },
                new { AvailableSportsId = 5, SportCentarsId = 9 },
                new { AvailableSportsId = 1, SportCentarsId = 9 },
                new { AvailableSportsId = 4, SportCentarsId = 9 },
                new { AvailableSportsId = 2, SportCentarsId = 10 },
                new { AvailableSportsId = 4, SportCentarsId = 10 }
            );
        }

        // Join table: SportCenterAmenities (AmenitySportCenter) — columns: AvailableAmenitiesId, SportCentarsId
        private static void SeedSportCenterAmenities(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity("AmenitySportCenter").HasData(
                // SportCenter 1: amenities 1,2,3,4,5,6
                new { AvailableAmenitiesId = 1, SportCentarsId = 1 },
                new { AvailableAmenitiesId = 2, SportCentarsId = 1 },
                new { AvailableAmenitiesId = 3, SportCentarsId = 1 },
                new { AvailableAmenitiesId = 4, SportCentarsId = 1 },
                new { AvailableAmenitiesId = 5, SportCentarsId = 1 },
                new { AvailableAmenitiesId = 6, SportCentarsId = 1 },
                // SportCenter 2: amenities 1,2,3,4,5,6
                new { AvailableAmenitiesId = 1, SportCentarsId = 2 },
                new { AvailableAmenitiesId = 2, SportCentarsId = 2 },
                new { AvailableAmenitiesId = 3, SportCentarsId = 2 },
                new { AvailableAmenitiesId = 4, SportCentarsId = 2 },
                new { AvailableAmenitiesId = 5, SportCentarsId = 2 },
                new { AvailableAmenitiesId = 6, SportCentarsId = 2 },
                // SportCenter 3: amenities 1,2,3,4,6
                new { AvailableAmenitiesId = 1, SportCentarsId = 3 },
                new { AvailableAmenitiesId = 2, SportCentarsId = 3 },
                new { AvailableAmenitiesId = 3, SportCentarsId = 3 },
                new { AvailableAmenitiesId = 4, SportCentarsId = 3 },
                new { AvailableAmenitiesId = 6, SportCentarsId = 3 },
                // SportCenter 4: amenities 1,2,3,5,6
                new { AvailableAmenitiesId = 1, SportCentarsId = 4 },
                new { AvailableAmenitiesId = 2, SportCentarsId = 4 },
                new { AvailableAmenitiesId = 3, SportCentarsId = 4 },
                new { AvailableAmenitiesId = 5, SportCentarsId = 4 },
                new { AvailableAmenitiesId = 6, SportCentarsId = 4 },
                // SportCenter 5: amenities 1,2,3,4,6
                new { AvailableAmenitiesId = 1, SportCentarsId = 5 },
                new { AvailableAmenitiesId = 2, SportCentarsId = 5 },
                new { AvailableAmenitiesId = 3, SportCentarsId = 5 },
                new { AvailableAmenitiesId = 4, SportCentarsId = 5 },
                new { AvailableAmenitiesId = 6, SportCentarsId = 5 },
                // SportCenters 6-10: subset of amenities
                new { AvailableAmenitiesId = 1, SportCentarsId = 6 }, new { AvailableAmenitiesId = 2, SportCentarsId = 6 }, new { AvailableAmenitiesId = 3, SportCentarsId = 6 },
                new { AvailableAmenitiesId = 1, SportCentarsId = 7 }, new { AvailableAmenitiesId = 6, SportCentarsId = 7 },
                new { AvailableAmenitiesId = 1, SportCentarsId = 8 }, new { AvailableAmenitiesId = 2, SportCentarsId = 8 }, new { AvailableAmenitiesId = 4, SportCentarsId = 8 },
                new { AvailableAmenitiesId = 1, SportCentarsId = 9 }, new { AvailableAmenitiesId = 3, SportCentarsId = 9 }, new { AvailableAmenitiesId = 5, SportCentarsId = 9 },
                new { AvailableAmenitiesId = 1, SportCentarsId = 10 }, new { AvailableAmenitiesId = 2, SportCentarsId = 10 }, new { AvailableAmenitiesId = 3, SportCentarsId = 10 }, new { AvailableAmenitiesId = 4, SportCentarsId = 10 }, new { AvailableAmenitiesId = 5, SportCentarsId = 10 }, new { AvailableAmenitiesId = 6, SportCentarsId = 10 }
            );
        }

        private static void SeedWorkingHours(ModelBuilder modelBuilder)
        {
            var today = new DateOnly(2025, 1, 1);

            modelBuilder.Entity<WorkingHours>().HasData(
                new WorkingHours { Id = 1, SportCenterId = 1, StartDay = DayOfWeek.Monday,   EndDay = DayOfWeek.Friday,  OpeningHours = new TimeOnly(8, 0), CloseingHours = new TimeOnly(22, 0), ValidFrom = today, ValidTo = null },
                new WorkingHours { Id = 2, SportCenterId = 1, StartDay = DayOfWeek.Saturday, EndDay = DayOfWeek.Sunday,  OpeningHours = new TimeOnly(9, 0), CloseingHours = new TimeOnly(20, 0), ValidFrom = today, ValidTo = null },
                new WorkingHours { Id = 3, SportCenterId = 2, StartDay = DayOfWeek.Monday,   EndDay = DayOfWeek.Sunday,  OpeningHours = new TimeOnly(7, 0), CloseingHours = new TimeOnly(23, 0), ValidFrom = today, ValidTo = null },
                new WorkingHours { Id = 4, SportCenterId = 3, StartDay = DayOfWeek.Monday,   EndDay = DayOfWeek.Friday,  OpeningHours = new TimeOnly(6, 0), CloseingHours = new TimeOnly(21, 0), ValidFrom = today, ValidTo = null },
                new WorkingHours { Id = 5, SportCenterId = 3, StartDay = DayOfWeek.Saturday, EndDay = DayOfWeek.Sunday,  OpeningHours = new TimeOnly(8, 0), CloseingHours = new TimeOnly(19, 0), ValidFrom = today, ValidTo = null },
                new WorkingHours { Id = 6, SportCenterId = 4, StartDay = DayOfWeek.Monday,   EndDay = DayOfWeek.Sunday,  OpeningHours = new TimeOnly(8, 0), CloseingHours = new TimeOnly(22, 0), ValidFrom = today, ValidTo = null },
                new WorkingHours { Id = 7, SportCenterId = 5, StartDay = DayOfWeek.Monday,   EndDay = DayOfWeek.Sunday,  OpeningHours = new TimeOnly(9, 0), CloseingHours = new TimeOnly(23, 0), ValidFrom = today, ValidTo = null },
                new WorkingHours { Id = 8, SportCenterId = 6, StartDay = DayOfWeek.Monday,   EndDay = DayOfWeek.Sunday,  OpeningHours = new TimeOnly(8, 0), CloseingHours = new TimeOnly(23, 0), ValidFrom = today, ValidTo = null },
                new WorkingHours { Id = 9, SportCenterId = 7, StartDay = DayOfWeek.Monday,   EndDay = DayOfWeek.Sunday,  OpeningHours = new TimeOnly(7, 0), CloseingHours = new TimeOnly(22, 0), ValidFrom = today, ValidTo = null },
                new WorkingHours { Id = 10, SportCenterId = 8, StartDay = DayOfWeek.Monday,   EndDay = DayOfWeek.Sunday,  OpeningHours = new TimeOnly(8, 0), CloseingHours = new TimeOnly(21, 0), ValidFrom = today, ValidTo = null },
                new WorkingHours { Id = 11, SportCenterId = 9, StartDay = DayOfWeek.Monday,   EndDay = DayOfWeek.Sunday,  OpeningHours = new TimeOnly(9, 0), CloseingHours = new TimeOnly(22, 0), ValidFrom = today, ValidTo = null },
                new WorkingHours { Id = 12, SportCenterId = 10, StartDay = DayOfWeek.Monday,  EndDay = DayOfWeek.Sunday,  OpeningHours = new TimeOnly(6, 0), CloseingHours = new TimeOnly(23, 59), ValidFrom = today, ValidTo = null }
            );
        }

        private static void SeedFacilities(ModelBuilder modelBuilder)
        {
            var createdAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc);

            modelBuilder.Entity<Facility>().HasData(
                new Facility { Id = 1, Name = "Main Football Field", MaxCapacity = 22, IsDynamicPricing = true,  StaticPrice = null,    IsIndoor = false, Duration = TimeSpan.FromHours(1.5), SportCenterId = 1, TurfTypeId = 2, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 2, Name = "Basketball Court A",  MaxCapacity = 10, IsDynamicPricing = false, StaticPrice = 50.00m,  IsIndoor = true,  Duration = TimeSpan.FromHours(1),   SportCenterId = 2, TurfTypeId = 5, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 3, Name = "Tennis Court 1",      MaxCapacity = 4,  IsDynamicPricing = true,  StaticPrice = null,    IsIndoor = false, Duration = TimeSpan.FromHours(1),   SportCenterId = 3, TurfTypeId = 4, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 4, Name = "Volleyball Court",    MaxCapacity = 12, IsDynamicPricing = false, StaticPrice = 40.00m,  IsIndoor = true,  Duration = TimeSpan.FromHours(1.5), SportCenterId = 2, TurfTypeId = 5, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 5, Name = "Basketball Court 1",   MaxCapacity = 10,  IsDynamicPricing = false, StaticPrice = 30.00m,  IsIndoor = true,  Duration = TimeSpan.FromHours(1),   SportCenterId = 4, TurfTypeId = 5, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 6, Name = "Volleyball Area",   MaxCapacity = 12,  IsDynamicPricing = false, StaticPrice = 20.00m,  IsIndoor = true,  Duration = TimeSpan.FromHours(1),   SportCenterId = 4, TurfTypeId = 5, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 7, Name = "Indoor Court",MaxCapacity = 14,IsDynamicPricing = true,  StaticPrice = null,    IsIndoor = true,  Duration = TimeSpan.FromHours(1.5), SportCenterId = 5, TurfTypeId = 5, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 8, Name = "Zenica Football Field",MaxCapacity = 22,IsDynamicPricing = false, StaticPrice = 80.00m,  IsIndoor = false, Duration = TimeSpan.FromHours(1.5), SportCenterId = 6, TurfTypeId = 2, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 9, Name = "Zenica Basketball Court",MaxCapacity = 10,IsDynamicPricing = false, StaticPrice = 40.00m,IsIndoor = true,  Duration = TimeSpan.FromHours(1),   SportCenterId = 6, TurfTypeId = 5, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 10, Name = "Doboj Main Field",   MaxCapacity = 22, IsDynamicPricing = false, StaticPrice = 60.00m,  IsIndoor = false, Duration = TimeSpan.FromHours(1.5), SportCenterId = 7, TurfTypeId = 1, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 11, Name = "Doboj Training Field",MaxCapacity = 14,IsDynamicPricing = false, StaticPrice = 40.00m,  IsIndoor = false, Duration = TimeSpan.FromHours(1.5), SportCenterId = 7, TurfTypeId = 2, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 12, Name = "Travnik Center Court",MaxCapacity = 4,IsDynamicPricing = false, StaticPrice = 50.00m, IsIndoor = false, Duration = TimeSpan.FromHours(1),   SportCenterId = 8, TurfTypeId = 4, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 13, Name = "Travnik Court 2",  MaxCapacity = 4,  IsDynamicPricing = false, StaticPrice = 30.00m,  IsIndoor = false, Duration = TimeSpan.FromHours(1),   SportCenterId = 8, TurfTypeId = 3, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 14, Name = "Travnik Court 3",  MaxCapacity = 4,  IsDynamicPricing = false, StaticPrice = 30.00m,  IsIndoor = false, Duration = TimeSpan.FromHours(1),   SportCenterId = 8, TurfTypeId = 3, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 15, Name = "Konjic Court",MaxCapacity=14,IsDynamicPricing= false, StaticPrice = 45.00m,  IsIndoor = true,  Duration = TimeSpan.FromHours(1.5), SportCenterId = 9, TurfTypeId = 5, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 16, Name = "Main Court", MaxCapacity = 20, IsDynamicPricing = false, StaticPrice = 100.00m, IsIndoor = true,  Duration = TimeSpan.FromHours(1),   SportCenterId = 10, TurfTypeId = 5, CreatedAt = createdAt, UpdatedAt = createdAt },
                new Facility { Id = 17, Name = "Secondary Court",MaxCapacity=12,IsDynamicPricing=false,  StaticPrice = 70.00m,  IsIndoor = true,  Duration = TimeSpan.FromHours(1),   SportCenterId = 10, TurfTypeId = 5, CreatedAt = createdAt, UpdatedAt = createdAt }
            );
        }

        private static void SeedFacilitySports(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity("FacilitySport").HasData(
                new { AvailableSportsId = 1, FacilitiesId = 1 },  
                new { AvailableSportsId = 2, FacilitiesId = 2 },  
                new { AvailableSportsId = 3, FacilitiesId = 3 },  
                new { AvailableSportsId = 4, FacilitiesId = 4 },  
                new { AvailableSportsId = 2, FacilitiesId = 5 },  
                new { AvailableSportsId = 4, FacilitiesId = 6 },  
                new { AvailableSportsId = 5, FacilitiesId = 7 },  
                new { AvailableSportsId = 1, FacilitiesId = 7 },  
                new { AvailableSportsId = 4, FacilitiesId = 7 },  
                new { AvailableSportsId = 1, FacilitiesId = 8 },  
                new { AvailableSportsId = 2, FacilitiesId = 9 },  
                new { AvailableSportsId = 1, FacilitiesId = 10 }, 
                new { AvailableSportsId = 1, FacilitiesId = 11 }, 
                new { AvailableSportsId = 3, FacilitiesId = 12 }, 
                new { AvailableSportsId = 3, FacilitiesId = 13 }, 
                new { AvailableSportsId = 3, FacilitiesId = 14 }, 
                new { AvailableSportsId = 5, FacilitiesId = 15 }, 
                new { AvailableSportsId = 1, FacilitiesId = 15 }, 
                new { AvailableSportsId = 4, FacilitiesId = 15 }, 
                new { AvailableSportsId = 2, FacilitiesId = 16 }, 
                new { AvailableSportsId = 4, FacilitiesId = 16 }, 
                new { AvailableSportsId = 2, FacilitiesId = 17 }  
            );
        }

        private static void SeedFacilityDynamicPrices(ModelBuilder modelBuilder)
        {
            var today = new DateOnly(2025, 1, 1);

            modelBuilder.Entity<FacilityDynamicPrice>().HasData(
                new FacilityDynamicPrice
                {
                    Id = 1,
                    FacilityId = 1,
                    StartDay = DayOfWeek.Monday,
                    EndDay = DayOfWeek.Friday,
                    StartTime = new TimeOnly(8, 0),
                    EndTime = new TimeOnly(17, 0),
                    PricePerHour = 60.00m,
                    ValidFrom = today,
                    ValidTo = null
                },
                new FacilityDynamicPrice
                {
                    Id = 2,
                    FacilityId = 1,
                    StartDay = DayOfWeek.Monday,
                    EndDay = DayOfWeek.Friday,
                    StartTime = new TimeOnly(17, 0),
                    EndTime = new TimeOnly(22, 0),
                    PricePerHour = 80.00m,
                    ValidFrom = today,
                    ValidTo = null
                },
                new FacilityDynamicPrice
                {
                    Id = 3,
                    FacilityId = 1,
                    StartDay = DayOfWeek.Saturday,
                    EndDay = DayOfWeek.Sunday,
                    StartTime = new TimeOnly(9, 0),
                    EndTime = new TimeOnly(20, 0),
                    PricePerHour = 90.00m,
                    ValidFrom = today,
                    ValidTo = null
                },
                new FacilityDynamicPrice
                {
                    Id = 4,
                    FacilityId = 3,
                    StartDay = DayOfWeek.Monday,
                    EndDay = DayOfWeek.Friday,
                    StartTime = new TimeOnly(6, 0),
                    EndTime = new TimeOnly(21, 0),
                    PricePerHour = 45.00m,
                    ValidFrom = today,
                    ValidTo = null
                },
                new FacilityDynamicPrice
                {
                    Id = 5,
                    FacilityId = 3,
                    StartDay = DayOfWeek.Saturday,
                    EndDay = DayOfWeek.Sunday,
                    StartTime = new TimeOnly(8, 0),
                    EndTime = new TimeOnly(19, 0),
                    PricePerHour = 55.00m,
                    ValidFrom = today,
                    ValidTo = null
                },
                new FacilityDynamicPrice
                {
                    Id = 6,
                    FacilityId = 7,
                    StartDay = DayOfWeek.Monday,
                    EndDay = DayOfWeek.Friday,
                    StartTime = new TimeOnly(8, 0),
                    EndTime = new TimeOnly(15, 0),
                    PricePerHour = 50.00m,
                    ValidFrom = today,
                    ValidTo = null
                },
                new FacilityDynamicPrice
                {
                    Id = 7,
                    FacilityId = 7,
                    StartDay = DayOfWeek.Monday,
                    EndDay = DayOfWeek.Friday,
                    StartTime = new TimeOnly(16, 0),
                    EndTime = new TimeOnly(23, 0),
                    PricePerHour = 70.00m,
                    ValidFrom = today,
                    ValidTo = null
                },
                new FacilityDynamicPrice
                {
                    Id = 8,
                    FacilityId = 7,
                    StartDay = DayOfWeek.Saturday,
                    EndDay = DayOfWeek.Sunday,
                    StartTime = new TimeOnly(9, 0),
                    EndTime = new TimeOnly(23, 0),
                    PricePerHour = 80.00m,
                    ValidFrom = today,
                    ValidTo = null
                },
                new FacilityDynamicPrice
                {
                    Id = 9,
                    FacilityId = 10,
                    StartDay = DayOfWeek.Monday,
                    EndDay = DayOfWeek.Friday,
                    StartTime = new TimeOnly(8, 0),
                    EndTime = new TimeOnly(16, 0),
                    PricePerHour = 50.00m,
                    ValidFrom = today,
                    ValidTo = null
                },
                new FacilityDynamicPrice
                {
                    Id = 10,
                    FacilityId = 10,
                    StartDay = DayOfWeek.Monday,
                    EndDay = DayOfWeek.Friday,
                    StartTime = new TimeOnly(16, 0),
                    EndTime = new TimeOnly(22, 0),
                    PricePerHour = 75.00m,
                    ValidFrom = today,
                    ValidTo = null
                },
                new FacilityDynamicPrice
                {
                    Id = 11,
                    FacilityId = 12,
                    StartDay = DayOfWeek.Saturday,
                    EndDay = DayOfWeek.Sunday,
                    StartTime = new TimeOnly(8, 0),
                    EndTime = new TimeOnly(20, 0),
                    PricePerHour = 60.00m,
                    ValidFrom = today,
                    ValidTo = null
                },
                new FacilityDynamicPrice
                {
                    Id = 12,
                    FacilityId = 10,
                    StartDay = DayOfWeek.Saturday,
                    EndDay = DayOfWeek.Sunday,
                    StartTime = new TimeOnly(8, 0),
                    EndTime = new TimeOnly(22, 0),
                    PricePerHour = 60.00m,
                    ValidFrom = today,
                    ValidTo = null
                }
            );
        }
        private static void SeedReservations(ModelBuilder modelBuilder)
        {
            var currentDate = DateOnly.FromDateTime(DateTime.UtcNow);

            var dateJan = new DateOnly(2026, 1, 20);
            var dateFeb = new DateOnly(2026, 2, 25);
            var dateMar = new DateOnly(2026, 3, 15);
            var dateApr = new DateOnly(2026, 4, 10);
            var dateMay = new DateOnly(2026, 5, 5);
            var dateJun = new DateOnly(2026, 6, 15);
            var dateJul = new DateOnly(2026, 7, 20);
            var dateAugPast = new DateOnly(2026, 8, 10);
            var dateAugFuture = new DateOnly(2026, 8, 28);
            var dateSep = new DateOnly(2026, 9, 5);
            var dateOct = new DateOnly(2026, 10, 10);
            var dateNov = new DateOnly(2026, 11, 20);
            var dateDecFuture = new DateOnly(2026, 12, 15);

            var reservations = new List<Reservation>
            {
                new Reservation { Id = 1, UserId = 2, FacilityId = 1, ReservationDate = dateJan, StartTime = new TimeOnly(18, 0), EndTime = new TimeOnly(19, 30), Status = GetReservationStatus(dateJan,currentDate), Price = 80.00m, ChosenSportId = 1 },
                new Reservation { Id = 2, UserId = 3, FacilityId = 2, ReservationDate = dateFeb, StartTime = new TimeOnly(19, 0), EndTime = new TimeOnly(20, 0), Status = GetReservationStatus(dateFeb,currentDate), Price = 50.00m, ChosenSportId = 2 },
                new Reservation { Id = 3, UserId = 4, FacilityId = 3, ReservationDate = dateMar, StartTime = new TimeOnly(10, 0), EndTime = new TimeOnly(11, 0), Status = GetReservationStatus(dateMar,currentDate), Price = 45.00m, ChosenSportId = 3 },
                new Reservation { Id = 4, UserId = 2, FacilityId = 1, ReservationDate = dateApr, StartTime = new TimeOnly(20, 0), EndTime = new TimeOnly(21, 30), Status = GetReservationStatus(dateApr,currentDate), Price = 80.00m, ChosenSportId = 1 },
                new Reservation { Id = 5, UserId = 3, FacilityId = 4, ReservationDate = dateMay, StartTime = new TimeOnly(16, 0), EndTime = new TimeOnly(17, 30), Status = GetReservationStatus(dateMay,currentDate), Price = 40.00m, ChosenSportId = 4 },
                new Reservation { Id = 6, UserId = 5, FacilityId = 5, ReservationDate = dateJun, StartTime = new TimeOnly(18, 0), EndTime = new TimeOnly(19, 0), Status = GetReservationStatus(dateJun,currentDate), Price = 30.00m, ChosenSportId = 2 },
                new Reservation { Id = 7, UserId = 6, FacilityId = 6, ReservationDate = dateJul, StartTime = new TimeOnly(17, 0), EndTime = new TimeOnly(18, 0), Status = GetReservationStatus(dateJul,currentDate), Price = 20.00m, ChosenSportId = 4 },
                new Reservation { Id = 8, UserId = 7, FacilityId = 7, ReservationDate = dateAugPast, StartTime = new TimeOnly(20, 0), EndTime = new TimeOnly(21, 30), Status = GetReservationStatus(dateAugPast,currentDate), Price = 70.00m, ChosenSportId = 5 },
                new Reservation { Id = 9, UserId = 8, FacilityId = 8, ReservationDate = dateJan, StartTime = new TimeOnly(15, 0), EndTime = new TimeOnly(16, 30), Status = GetReservationStatus(dateJan,currentDate), Price = 80.00m, ChosenSportId = 1 },
                new Reservation { Id = 10, UserId = 2, FacilityId = 9, ReservationDate = dateFeb, StartTime = new TimeOnly(18, 0), EndTime = new TimeOnly(19, 0), Status = GetReservationStatus(dateFeb,currentDate), Price = 40.00m, ChosenSportId = 2 },
                new Reservation { Id = 11, UserId = 3, FacilityId = 10, ReservationDate = dateMar, StartTime = new TimeOnly(20, 0), EndTime = new TimeOnly(21, 30), Status = GetReservationStatus(dateMar,currentDate), Price = 60.00m, ChosenSportId = 1 },
                new Reservation { Id = 12, UserId = 4, FacilityId = 11, ReservationDate = dateApr, StartTime = new TimeOnly(19, 0), EndTime = new TimeOnly(20, 30), Status = GetReservationStatus(dateApr,currentDate), Price = 40.00m, ChosenSportId = 1 },
                new Reservation { Id = 13, UserId = 5, FacilityId = 12, ReservationDate = dateAugFuture, StartTime = new TimeOnly(10, 0), EndTime = new TimeOnly(11, 0), Status = GetReservationStatus(dateAugFuture,currentDate), Price = 50.00m, ChosenSportId = 3 },
                new Reservation { Id = 14, UserId = 6, FacilityId = 13, ReservationDate = dateSep, StartTime = new TimeOnly(11, 0), EndTime = new TimeOnly(12, 0), Status = GetReservationStatus(dateSep,currentDate), Price = 30.00m, ChosenSportId = 3 },
                new Reservation { Id = 15, UserId = 2, FacilityId = 14, ReservationDate = dateSep, StartTime = new TimeOnly(12, 0), EndTime = new TimeOnly(13, 0), Status = GetReservationStatus(dateSep,currentDate), Price = 30.00m, ChosenSportId = 3 },
                new Reservation { Id = 16, UserId = 7, FacilityId = 15, ReservationDate = dateOct, StartTime = new TimeOnly(18, 0), EndTime = new TimeOnly(19, 30), Status = GetReservationStatus(dateOct,currentDate), Price = 45.00m, ChosenSportId = 5 },
                new Reservation { Id = 17, UserId = 8, FacilityId = 16, ReservationDate = dateOct, StartTime = new TimeOnly(19, 0), EndTime = new TimeOnly(20, 0), Status = GetReservationStatus(dateOct,currentDate), Price = 100.00m, ChosenSportId = 2 },
                new Reservation { Id = 18, UserId = 9, FacilityId = 17, ReservationDate = dateNov, StartTime = new TimeOnly(20, 0), EndTime = new TimeOnly(21, 0), Status = GetReservationStatus(dateNov,currentDate), Price = 70.00m, ChosenSportId = 2 },
                new Reservation { Id = 19, UserId = 10, FacilityId = 1, ReservationDate = dateNov, StartTime = new TimeOnly(17, 0), EndTime = new TimeOnly(18, 30), Status = GetReservationStatus(dateNov,currentDate), Price = 80.00m, ChosenSportId = 1 },
                new Reservation { Id = 20, UserId = 11, FacilityId = 2, ReservationDate = dateDecFuture, StartTime = new TimeOnly(18, 0), EndTime = new TimeOnly(19, 0), Status = GetReservationStatus(dateDecFuture,currentDate), Price = 50.00m, ChosenSportId = 2 }
            };

            var futureSeedDate = new DateOnly(2026, 9, 1);

            for (int i = 0; i < 10; i++)
            {
                var reservationDate = futureSeedDate.AddDays(i * 7);

                reservations.Add(new Reservation
                {
                    Id = 21 + i,
                    UserId = 2,
                    FacilityId = 5,
                    ReservationDate = reservationDate,
                    StartTime = new TimeOnly(20, 0),
                    EndTime = new TimeOnly(21, 0),
                    Status = GetReservationStatus(reservationDate,currentDate),
                    Price = 30.00m,
                    ChosenSportId = 2
                });
            }

            var pastSeedDate = new DateOnly(2026, 6, 1);

            for (int i = 0; i < 10; i++)
            {
                var reservationDate = pastSeedDate.AddDays(i * 7);

                reservations.Add(new Reservation
                {
                    Id = 31 + i,
                    UserId = 2,
                    FacilityId = 5,
                    ReservationDate = reservationDate,
                    StartTime = new TimeOnly(20, 0),
                    EndTime = new TimeOnly(21, 0),
                    Status = nameof(CompletedReservationState),
                    Price = 30.00m,
                    ChosenSportId = 2
                });
            }

            for (int i = 0; i < 3; i++)
            {
                var reservationDate = futureSeedDate.AddDays(i * 7);

                reservations.Add(new Reservation
                {
                    Id = 41 + i,
                    UserId = 3,
                    FacilityId = 5,
                    ReservationDate = reservationDate,
                    StartTime = new TimeOnly(11, 0),
                    EndTime = new TimeOnly(12, 0),
                    Status = GetReservationStatus(reservationDate,currentDate),
                    Price = 30.00m,
                    ChosenSportId = 2
                });
            }

            for (int i = 0; i < 3; i++)
            {
                var reservationDate = pastSeedDate.AddDays(i * 7);

                reservations.Add(new Reservation
                {
                    Id = 44 + i,
                    UserId = 3,
                    FacilityId = 5,
                    ReservationDate = reservationDate,
                    StartTime = new TimeOnly(11, 0),
                    EndTime = new TimeOnly(12, 0),
                    Status = nameof(CompletedReservationState),
                    Price = 30.00m,
                    ChosenSportId = 2
                });
            }

            reservations.AddRange(
                new[]
                {
                    new Reservation
                    {
                        Id = 47,
                        UserId = 2,
                        FacilityId = 1,
                        ReservationDate = new DateOnly(2026, 9, 17),
                        StartTime = new TimeOnly(17, 0),
                        EndTime = new TimeOnly(18, 30),
                        Status = GetReservationStatus(new DateOnly(2026, 9, 17), currentDate),
                        Price = 80.00m,
                        ChosenSportId = 1
                    },
                    new Reservation
                    {
                        Id = 48,
                        UserId = 2,
                        FacilityId = 1,
                        ReservationDate = new DateOnly(2026, 9, 19),
                        StartTime = new TimeOnly(18, 0),
                        EndTime = new TimeOnly(19, 30),
                        Status = GetReservationStatus(new DateOnly(2026, 9, 19), currentDate),
                        Price = 90.00m,
                        ChosenSportId = 1
                    }
                }
            );

            var additionalReservations = new[]
            {
                // Facility 5 — Basketball Court 1 — 30.00m per one-hour slot
                new { Id = 49, UserId = 3, FacilityId = 5, Date = new DateOnly(2026, 7, 2),  Start = new TimeOnly(8, 0),  End = new TimeOnly    (   9,     0),  Price = 30.00m, SportId = 2 },
                new { Id = 50, UserId = 4, FacilityId = 5, Date = new DateOnly(2026, 7, 9),  Start = new TimeOnly(12, 0), End = new TimeOnly    (   13,    0), Price = 30.00m, SportId = 2 },
                new { Id = 51, UserId = 5, FacilityId = 5, Date = new DateOnly(2026, 7, 21), Start = new TimeOnly(19, 0), End = new TimeOnly    (   20,    0), Price = 30.00m, SportId = 2 },
                new { Id = 52, UserId = 6, FacilityId = 5, Date = new DateOnly(2026, 8, 4),  Start = new TimeOnly(10, 0), End = new TimeOnly    (   11,    0), Price = 30.00m, SportId = 2 },
                new { Id = 53, UserId = 7, FacilityId = 5, Date = new DateOnly(2026, 8, 13), Start = new TimeOnly(15, 0), End = new TimeOnly    (   16,    0), Price = 30.00m, SportId = 2 },
                new { Id = 54, UserId = 8, FacilityId = 5, Date = new DateOnly(2026, 8, 25), Start = new TimeOnly(20, 0), End = new TimeOnly    (   21,    0), Price = 30.00m, SportId = 2 },
                new { Id = 55, UserId = 9, FacilityId = 5, Date = new DateOnly(2026, 9, 3),  Start = new TimeOnly(9, 0),  End = new TimeOnly    (   10,    0), Price = 30.00m, SportId = 2 },
                new { Id = 56, UserId = 10, FacilityId = 5, Date = new DateOnly(2026, 9, 15), Start = new TimeOnly(14, 0), End = new    TimeOnly   (15,   0), Price = 30.00m, SportId = 2 },
                new { Id = 57, UserId = 11, FacilityId = 5, Date = new DateOnly(2026, 9, 29), Start = new TimeOnly(18, 0), End = new    TimeOnly   (19,   0), Price = 30.00m, SportId = 2 },
            
                // Facility 6 — Volleyball Area — 20.00m per one-hour slot
                new { Id = 58, UserId = 4, FacilityId = 6, Date = new DateOnly(2026, 7, 7),  Start = new TimeOnly(9, 0),  End = new TimeOnly    (   10,    0), Price = 20.00m, SportId = 4 },
                new { Id = 59, UserId = 5, FacilityId = 6, Date = new DateOnly(2026, 7, 16), Start = new TimeOnly(13, 0), End = new TimeOnly    (   14,    0), Price = 20.00m, SportId = 4 },
                new { Id = 60, UserId = 6, FacilityId = 6, Date = new DateOnly(2026, 7, 28), Start = new TimeOnly(18, 0), End = new TimeOnly    (   19,    0), Price = 20.00m, SportId = 4 },
                new { Id = 61, UserId = 7, FacilityId = 6, Date = new DateOnly(2026, 8, 6),  Start = new TimeOnly(8, 0),  End = new TimeOnly    (   9,     0),  Price = 20.00m, SportId = 4 },
                new { Id = 62, UserId = 8, FacilityId = 6, Date = new DateOnly(2026, 8, 18), Start = new TimeOnly(11, 0), End = new TimeOnly    (   12,    0), Price = 20.00m, SportId = 4 },
                new { Id = 63, UserId = 9, FacilityId = 6, Date = new DateOnly(2026, 8, 27), Start = new TimeOnly(16, 0), End = new TimeOnly    (   17,    0), Price = 20.00m, SportId = 4 },
                new { Id = 64, UserId = 10, FacilityId = 6, Date = new DateOnly(2026, 9, 8), Start = new TimeOnly(10, 0), End = new TimeOnly    (   11,    0), Price = 20.00m, SportId = 4 },
                new { Id = 65, UserId = 11, FacilityId = 6, Date = new DateOnly(2026, 9, 17), Start = new TimeOnly(15, 0), End = new    TimeOnly   (16,   0), Price = 20.00m, SportId = 4 },
                new { Id = 66, UserId = 3, FacilityId = 6, Date = new DateOnly(2026, 9, 24), Start = new TimeOnly(20, 0), End = new TimeOnly    (   21,    0), Price = 20.00m, SportId = 4 }
            };

            foreach (var item in additionalReservations)
            {
                reservations.Add(new Reservation
                {
                    Id = item.Id,
                    UserId = item.UserId,
                    FacilityId = item.FacilityId,
                    ReservationDate = item.Date,
                    StartTime = item.Start,
                    EndTime = item.End,
                    Status = GetReservationStatus(item.Date, currentDate),
                    Price = item.Price,
                    ChosenSportId = item.SportId
                });
            }

            var canceledReservationDate = new DateOnly(2026, 9, 3);



            modelBuilder.Entity<Reservation>().HasData(reservations);
        }
private static void SeedPosts(ModelBuilder modelBuilder)
{
    var currentDate = DateOnly.FromDateTime(DateTime.UtcNow);

    var posts = new List<Post>
    {
        new Post
        {
            Id = 1,
            SkillLevel = "Medium",
            NumberOfPlayersWanted = 3,
            NumberOfPlayersFound = 1,
            Text = "Looking for players for a friendly match",
            ReservationId = 1,
            PostState = GetPostState(
                new DateOnly(2026, 1, 20),
                currentDate,
                3,
                1)
        },
        new Post
        {
            Id = 2,
            SkillLevel = "Beginner",
            NumberOfPlayersWanted = 2,
            NumberOfPlayersFound = 0,
            Text = "Need players for basketball game",
            ReservationId = 2,
            PostState = GetPostState(
                new DateOnly(2026, 2, 25),
                currentDate,
                2,
                0)
        },
        new Post
        {
            Id = 3,
            SkillLevel = "Advanced",
            NumberOfPlayersWanted = 1,
            NumberOfPlayersFound = 1,
            Text = "Looking for a tennis partner",
            ReservationId = 3,
            PostState = GetPostState(
                new DateOnly(2026, 3, 15),
                currentDate,
                1,
                1)
        },
        new Post
        {
            Id = 4,
            SkillLevel = "Medium",
            NumberOfPlayersWanted = 4,
            NumberOfPlayersFound = 2,
            Text = "Football match - need more players",
            ReservationId = 4,
            PostState = GetPostState(
                new DateOnly(2026, 4, 10),
                currentDate,
                4,
                2)
        },
        new Post
        {
            Id = 5,
            SkillLevel = "Medium",
            NumberOfPlayersWanted = 2,
            NumberOfPlayersFound = 0,
            Text = "Volleyball players needed",
            ReservationId = 5,
            PostState = GetPostState(
                new DateOnly(2026, 5, 5),
                currentDate,
                2,
                0)
        },
        new Post
        {
            Id = 6,
            SkillLevel = "Beginner",
            NumberOfPlayersWanted = 5,
            NumberOfPlayersFound = 2,
            Text = "Casual basketball game",
            ReservationId = 6,
            PostState = GetPostState(
                new DateOnly(2026, 6, 15),
                currentDate,
                5,
                2)
        }
    };

    var futureSeedDate = new DateOnly(2026, 9, 1);

    for (int i = 0; i < 5; i++)
    {
        var reservationDate = futureSeedDate.AddDays(i * 7);
        int playersWanted = 2;
        int playersFound = i % 2 == 0 ? 1 : 2;

        posts.Add(new Post
        {
            Id = 7 + i,
            SkillLevel = "Medium",
            NumberOfPlayersWanted = playersWanted,
            NumberOfPlayersFound = playersFound,
            Text = "Looking for players for a friendly match",
            ReservationId = 21 + i,
            PostState = GetPostState(
                reservationDate,
                currentDate,
                playersWanted,
                playersFound)
        });
    }

    var pastSeedDate = new DateOnly(2026, 6, 1);

    for (int i = 0; i < 5; i++)
    {
        var reservationDate = pastSeedDate.AddDays(i * 7);
        int playersWanted = 2;
        int playersFound = i % 2 == 0 ? 1 : 2;

        posts.Add(new Post
        {
            Id = 12 + i,
            SkillLevel = "Medium",
            NumberOfPlayersWanted = playersWanted,
            NumberOfPlayersFound = playersFound,
            Text = "Looking for players for a friendly match",
            ReservationId = 31 + i,
            PostState = GetPostState(
                reservationDate,
                currentDate,
                playersWanted,
                playersFound)
        });
    }

    for (int i = 0; i < 3; i++)
    {
        var reservationDate = futureSeedDate.AddDays(i * 7);
        int playersWanted = 3;
        int playersFound = i  switch 
        {
            0 => 0,
            1 => 2,
            _ => 3
        };
    
        posts.Add(new Post
        {
            Id = 17 + i,
            SkillLevel = i == 0
                ? "Beginner"
                : "Medium",
            NumberOfPlayersWanted = playersWanted,
            NumberOfPlayersFound = playersFound,
            Text = i switch
            {
                0 => "Looking for players for a casual basketball game",
                1 => "Need one more player for a basketball game",
                _ => "Basketball game is full, see you on the court"
            },
            ReservationId = 41 + i,
            PostState = GetPostState(
                reservationDate,
                currentDate,
                playersWanted,
                playersFound)
        });
    }



            modelBuilder.Entity<Post>().HasData(posts);
}

private static void SeedPlayRequests(ModelBuilder modelBuilder)
{
    var currentDate = DateOnly.FromDateTime(DateTime.UtcNow);

    var playRequests = new List<PlayRequest>
    {
        new PlayRequest
        {
            Id = 1,
            PostId = 1,
            RequesterId = 10,
            PlayRequestState = nameof(AcceptedPlayRequestState),
            RequestText = "I'd like to join your game",
            DateOfRequest = new DateTime(2026, 1, 11, 10, 0, 0, DateTimeKind.Utc),
            DateOfResponse = new DateTime(2026, 1, 12, 10, 0, 0, DateTimeKind.Utc)
        },
        new PlayRequest
        {
            Id = 2,
            PostId = 2,
            RequesterId = 11,
            PlayRequestState = nameof(RejectedPlayRequestState),
            RequestText = "Can I join?",
            DateOfRequest = new DateTime(2026, 2, 20, 10, 0, 0, DateTimeKind.Utc),
            DateOfResponse = new DateTime(2026, 2, 21, 10, 0, 0, DateTimeKind.Utc)
        },
        new PlayRequest
        {
            Id = 3,
            PostId = 3,
            RequesterId = 2,
            PlayRequestState = nameof(AcceptedPlayRequestState),
            RequestText = "I'm available for tennis",
            DateOfRequest = new DateTime(2026, 3, 10, 10, 0, 0, DateTimeKind.Utc),
            DateOfResponse = new DateTime(2026, 3, 12, 10, 0, 0, DateTimeKind.Utc)
        },
        new PlayRequest
        {
            Id = 4,
            PostId = 4,
            RequesterId = 3,
            PlayRequestState = nameof(AcceptedPlayRequestState),
            RequestText = "Count me in for football",
            DateOfRequest = new DateTime(2026, 4, 1, 10, 0, 0, DateTimeKind.Utc),
            DateOfResponse = new DateTime(2026, 4, 2, 10, 0, 0, DateTimeKind.Utc)
        },
        new PlayRequest
        {
            Id = 5,
            PostId = 4,
            RequesterId = 6,
            PlayRequestState = nameof(AcceptedPlayRequestState),
            RequestText = "I want to play",
            DateOfRequest = new DateTime(2026, 4, 3, 10, 0, 0, DateTimeKind.Utc),
            DateOfResponse = new DateTime(2026, 4, 5, 10, 0, 0, DateTimeKind.Utc)
        }
    };

    var postSchedules = new[]
    {
        new { PostId = 1, ReservationDate = new DateOnly(2026, 1, 20), ReservationStart = new TimeOnly(18, 0), PlayersWanted = 3, PlayersFound = 1 },
        new { PostId = 4, ReservationDate = new DateOnly(2026, 4, 10), ReservationStart = new TimeOnly(20, 0), PlayersWanted = 4, PlayersFound = 2 },
        new { PostId = 7, ReservationDate = new DateOnly(2026, 9, 1), ReservationStart = new TimeOnly(20, 0), PlayersWanted = 2, PlayersFound = 1 },
        new { PostId = 8, ReservationDate = new DateOnly(2026, 9, 8), ReservationStart = new TimeOnly(20, 0), PlayersWanted = 2, PlayersFound = 2 },
        new { PostId = 9, ReservationDate = new DateOnly(2026, 9, 15), ReservationStart = new TimeOnly(20, 0), PlayersWanted = 2, PlayersFound = 1 },
        new { PostId = 10, ReservationDate = new DateOnly(2026, 9, 22), ReservationStart = new TimeOnly(20, 0), PlayersWanted = 2, PlayersFound = 2 },
        new { PostId = 11, ReservationDate = new DateOnly(2026, 9, 29), ReservationStart = new TimeOnly(20, 0), PlayersWanted = 2, PlayersFound = 1 },
        new { PostId = 12, ReservationDate = new DateOnly(2026, 6, 1), ReservationStart = new TimeOnly(20, 0), PlayersWanted = 2, PlayersFound = 1 },
        new { PostId = 13, ReservationDate = new DateOnly(2026, 6, 8), ReservationStart = new TimeOnly(20, 0), PlayersWanted = 2, PlayersFound = 2 },
        new { PostId = 14, ReservationDate = new DateOnly(2026, 6, 15), ReservationStart = new TimeOnly(20, 0), PlayersWanted = 2, PlayersFound = 1 },
        new { PostId = 15, ReservationDate = new DateOnly(2026, 6, 22), ReservationStart = new TimeOnly(20, 0), PlayersWanted = 2, PlayersFound = 2 },
        new { PostId = 16, ReservationDate = new DateOnly(2026, 6, 29), ReservationStart = new TimeOnly(20, 0), PlayersWanted = 2, PlayersFound = 1 }
    };

    int[] requesters = { 3, 4, 5, 6 };

    var used = new HashSet<(int PostId, int RequesterId)>();

    foreach (var request in playRequests)
    {
        used.Add((request.PostId, request.RequesterId));
    }

    int nextId = 6;
    int requesterIndex = 0;
    int stateIndex = 0;

    for (int i = 0; i < 7; i++)
    {
        int requesterId = requesters[requesterIndex % requesters.Length];
        requesterIndex++;

        var schedule = postSchedules.FirstOrDefault(x =>
            !used.Contains((x.PostId, requesterId)));

        if (schedule == null)
        {
            break;
        }

        string state = GetPlayRequestState(
            schedule.ReservationDate,
            currentDate,
            schedule.PlayersWanted,
            schedule.PlayersFound,
            stateIndex);

        DateTime reservationStartsAt = schedule.ReservationDate.ToDateTime(
            schedule.ReservationStart,
            DateTimeKind.Utc);

        DateTime requestDate = reservationStartsAt.AddDays(-7);

        DateTime? responseDate =
            state == nameof(PendingPlayRequestState)
                ? null
                : requestDate.AddDays(1);

        playRequests.Add(new PlayRequest
        {
            Id = nextId++,
            PostId = schedule.PostId,
            RequesterId = requesterId,
            PlayRequestState = state,
            RequestText = "Count me in!",
            DateOfRequest = requestDate,
            DateOfResponse = responseDate
        });

        used.Add((schedule.PostId, requesterId));
        stateIndex++;
    }



            modelBuilder.Entity<PlayRequest>().HasData(playRequests);
}

        private static void SeedFacilityReviews(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<FacilityReview>().HasData(
                new FacilityReview { Id = 1, RatingNumber = 5, RatingDate = new DateOnly(2026, 1, 21),  Comment = "Excellent facility, well maintained", UserId = 2, FacilityId = 1, ReservationId = 1 },
                new FacilityReview { Id = 2, RatingNumber = 4, RatingDate = new DateOnly(2026, 2, 26),  Comment = "Great court, good lighting",          UserId = 3, FacilityId = 2, ReservationId = 2 },
                new FacilityReview { Id = 3, RatingNumber = 5, RatingDate = new DateOnly(2026, 3, 16),  Comment = "Perfect tennis court",               UserId = 4, FacilityId = 3, ReservationId = 3 },
                new FacilityReview { Id = 4, RatingNumber = 4, RatingDate = new DateOnly(2026, 4, 11),  Comment = "Nice court",                          UserId = 2, FacilityId = 1, ReservationId = 4 },
                new FacilityReview { Id = 5, RatingNumber = 3, RatingDate = new DateOnly(2026, 5, 6),   Comment = "Could be better maintained",         UserId = 3, FacilityId = 4, ReservationId = 5 },
                new FacilityReview { Id = 6, RatingNumber = 5, RatingDate = new DateOnly(2026, 6, 16),  Comment = "Awesome court",                      UserId = 5, FacilityId = 5, ReservationId = 6 },
                new FacilityReview { Id = 7, RatingNumber = 4, RatingDate = new DateOnly(2026, 7, 21),  Comment = "Pretty solid",                       UserId = 6, FacilityId = 6, ReservationId = 7 },
                new FacilityReview { Id = 8, RatingNumber = 5, RatingDate = new DateOnly(2026, 8, 11),  Comment = "Amazing handball experience",        UserId = 7, FacilityId = 7, ReservationId = 8 },
                new FacilityReview { Id = 9, RatingNumber = 4, RatingDate = new DateOnly(2026, 1, 22),  Comment = "Good overall",                       UserId = 8, FacilityId = 8, ReservationId = 9 },
                new FacilityReview { Id = 10, RatingNumber = 5, RatingDate = new DateOnly(2026, 2, 27), Comment = "Loved it!",                          UserId = 2, FacilityId = 9, ReservationId = 10 }, 
                new FacilityReview { Id = 11, RatingNumber = 5,RatingDate = new DateOnly(2026, 6, 16), Comment = "Excellent basketball court and a great playing experience.",UserId = 2,FacilityId = 5,ReservationId = 33 },
                new FacilityReview { Id = 12,RatingNumber = 3,RatingDate = new DateOnly(2026, 6, 23), Comment = "The court was fine overall, but the changing area could be improved.",UserId = 2,FacilityId = 5,ReservationId = 34 }
            );
        }

        private static void SeedUserReviews(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<UserReview>().HasData( 
                new UserReview { Id = 1,RatingNumber = 5,RatingDate = new DateOnly(2026, 1, 21),Comment = "Great host and a very fair player.",ReviewerId = 2,ReviewedId = 10,ReservationId = 1},
                new UserReview { Id = 2,RatingNumber = 5,RatingDate = new DateOnly(2026, 3, 16),Comment = "Excellent sportsmanship and a great match.",ReviewerId = 4,ReviewedId = 2,ReservationId = 3},
                new UserReview { Id = 3,RatingNumber = 4,RatingDate = new DateOnly(2026, 4, 11),Comment = "Reliable player and well organized game.",ReviewerId = 2,ReviewedId = 3,ReservationId = 4},
                new UserReview { Id = 4,RatingNumber = 5,RatingDate = new DateOnly(2026, 4, 11),Comment = "Friendly host. I would gladly play again.",ReviewerId = 2,ReviewedId = 6,ReservationId = 4},
                new UserReview { Id = 5, RatingNumber = 3, RatingDate = new DateOnly(2026, 5, 6),  Comment = "Average player",           ReviewerId = 3, ReviewedId = 7,  ReservationId = 5 },
                new UserReview { Id = 6, RatingNumber = 5, RatingDate = new DateOnly(2026, 6, 16), Comment = "Fun to play with",         ReviewerId = 5, ReviewedId = 6,  ReservationId = 6 },
                new UserReview { Id = 7, RatingNumber = 4, RatingDate = new DateOnly(2026, 7, 21), Comment = "Decent skills",            ReviewerId = 6, ReviewedId = 8,  ReservationId = 7 },
                new UserReview { Id = 8, RatingNumber = 5, RatingDate = new DateOnly(2026, 8, 11), Comment = "Great attitude",           ReviewerId = 7, ReviewedId = 9,  ReservationId = 8 },
                new UserReview { Id = 9, RatingNumber = 4, RatingDate = new DateOnly(2026, 1, 22), Comment = "Good player",              ReviewerId = 8, ReviewedId = 10, ReservationId = 9 },
                new UserReview { Id = 10, RatingNumber = 5, RatingDate = new DateOnly(2026, 2, 27),Comment = "Would play again",         ReviewerId = 2, ReviewedId = 5,  ReservationId = 10 }
            );
        }

        private static void SeedSportCenterPhotos(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<SportCenterPhoto>().HasData(
                new SportCenterPhoto { Id = 1, SportCenterId = 1, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787510219/stadion_grbavica_1.jpg", PublicId = "stadion_grbavica_1" },
                new SportCenterPhoto { Id = 2, SportCenterId = 2, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512809/generic_sport_center_1.jpg", PublicId = "generic_sport_center_1" },
                new SportCenterPhoto { Id = 3, SportCenterId = 3, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512806/generic_sport_center_3.jpg", PublicId = "generic_sport_center_3" },
                new SportCenterPhoto { Id = 4, SportCenterId = 4, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1786198753/terminba/facility_photos/gnqjcwq9xkyubg6n15fr.jpg", PublicId = "terminba/facility_photos/gnqjcwq9xkyubg6n15fr" },
                new SportCenterPhoto { Id = 5, SportCenterId = 5, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512804/generic_sport_center_5.jpg", PublicId = "generic_sport_center_5" },
                new SportCenterPhoto { Id = 6, SportCenterId = 6, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512809/generic_sport_center_1.jpg", PublicId = "generic_sport_center_1" },
                new SportCenterPhoto { Id = 7, SportCenterId = 7, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512806/generic_sport_center_3.jpg", PublicId = "generic_sport_center_3" },
                new SportCenterPhoto { Id = 8, SportCenterId = 8, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512804/generic_sport_center_5.jpg", PublicId = "generic_sport_center_5" },
                new SportCenterPhoto { Id = 9, SportCenterId = 9, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512809/generic_sport_center_1.jpg", PublicId = "generic_sport_center_1" },
                new SportCenterPhoto { Id = 10, SportCenterId = 10, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787500716/ramiz_salcin_2.jpg", PublicId = "ramiz_salcin_2" },
                
                // Extra photos (2 per sport center)
                new SportCenterPhoto { Id = 11, SportCenterId = 1, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787510319/stadion_grbavica_2.jpg", PublicId = "stadion_grbavica_2" },
                new SportCenterPhoto { Id = 12, SportCenterId = 2, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512807/generic_sport_center_2.jpg", PublicId = "generic_sport_center_2" },
                new SportCenterPhoto { Id = 13, SportCenterId = 3, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512808/generic_sport_center_4.jpg", PublicId = "generic_sport_center_4" },
                new SportCenterPhoto { Id = 14, SportCenterId = 4, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1786198698/terminba/facility_photos/ve2y7t3mavtdliuhiobj.jpg", PublicId = "terminba/facility_photos/ve2y7t3mavtdliuhiobj" },
                new SportCenterPhoto { Id = 15, SportCenterId = 5, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512804/generic_sport_center_6.jpg", PublicId = "generic_sport_center_6" },
                new SportCenterPhoto { Id = 16, SportCenterId = 6, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512807/generic_sport_center_2.jpg", PublicId = "generic_sport_center_2" },
                new SportCenterPhoto { Id = 17, SportCenterId = 7, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512808/generic_sport_center_4.jpg", PublicId = "generic_sport_center_4" },
                new SportCenterPhoto { Id = 18, SportCenterId = 8, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512804/generic_sport_center_6.jpg", PublicId = "generic_sport_center_6" },
                new SportCenterPhoto { Id = 19, SportCenterId = 9, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787512807/generic_sport_center_2.jpg", PublicId = "generic_sport_center_2" },
                new SportCenterPhoto { Id = 20, SportCenterId = 10, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787500716/ramiz_salcin_1.jpg", PublicId = "ramiz_salcin_1" }
            );
        }

        private static void SeedFacilityPhotos(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<FacilityPhoto>().HasData(
                new FacilityPhoto { Id = 1, FacilityId = 1, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787510460/stadion_grbavica_teren_1.jpg", PublicId = "stadion_grbavica_teren_1" },
                new FacilityPhoto { Id = 2, FacilityId = 2, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514242/generic_facility_court_1.jpg", PublicId = "generic_facility_court_1" },
                new FacilityPhoto { Id = 3, FacilityId = 3, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514594/generic_tennis_facility_court_1.jpg", PublicId = "generic_tennis_facility_court_1" },
                new FacilityPhoto { Id = 4, FacilityId = 4, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514248/generic_facility_court_3.jpg", PublicId = "generic_facility_court_3" },
                new FacilityPhoto { Id = 5, FacilityId = 5, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1786048421/terminba/facility_photos/dsleufbrkovgfqel3mui.jpg", PublicId = "terminba/facility_photos/dsleufbrkovgfqel3mui" },
                new FacilityPhoto { Id = 6, FacilityId = 6, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1786048421/terminba/facility_photos/dsleufbrkovgfqel3mui.jpg", PublicId = "terminba/facility_photos/dsleufbrkovgfqel3mui" },
                new FacilityPhoto { Id = 7, FacilityId = 7, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514238/generic_facility_court_5.jpg", PublicId = "generic_facility_court_5" },
                new FacilityPhoto { Id = 8, FacilityId = 8, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787515291/generic_football_facility_court_1.jpg", PublicId = "generic_football_facility_court_1" },
                new FacilityPhoto { Id = 9, FacilityId = 9, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514242/generic_facility_court_1.jpg", PublicId = "generic_facility_court_1" },
                new FacilityPhoto { Id = 10, FacilityId = 10, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787515289/generic_football_facility_court_3.jpg", PublicId = "generic_football_facility_court_3" },
                new FacilityPhoto { Id = 11, FacilityId = 11, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787515291/generic_football_facility_court_1.jpg", PublicId = "generic_football_facility_court_1" },
                new FacilityPhoto { Id = 12, FacilityId = 12, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514594/generic_tennis_facility_court_1.jpg", PublicId = "generic_tennis_facility_court_1" },
                new FacilityPhoto { Id = 13, FacilityId = 13, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514594/generic_tennis_facility_court_1.jpg", PublicId = "generic_tennis_facility_court_1" },
                new FacilityPhoto { Id = 14, FacilityId = 14, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514594/generic_tennis_facility_court_1.jpg", PublicId = "generic_tennis_facility_court_1" },
                new FacilityPhoto { Id = 15, FacilityId = 15, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514248/generic_facility_court_3.jpg", PublicId = "generic_facility_court_3" },
                new FacilityPhoto { Id = 16, FacilityId = 16, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787500868/ramiz_salcin_sala_1.jpg", PublicId = "ramiz_salcin_sala_1" },
                new FacilityPhoto { Id = 17, FacilityId = 17, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787500868/ramiz_salcin_sala_2.jpg", PublicId = "ramiz_salcin_sala_1" },
            
                // 2nd photo for all facilities
                new FacilityPhoto { Id = 18, FacilityId = 1, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787510497/stadion_grbavica_teren_2.jpg", PublicId = "stadion_grbavica_teren_2" },
                new FacilityPhoto { Id = 19, FacilityId = 2, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514239/generic_facility_court_2.jpg", PublicId = "generic_facility_court_2" },
                new FacilityPhoto { Id = 20, FacilityId = 3, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514595/generic_tennis_facility_court_2.jpg", PublicId = "generic_tennis_facility_court_2" },
                new FacilityPhoto { Id = 21, FacilityId = 4, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514239/generic_facility_court_4.jpg", PublicId = "generic_facility_court_4" },
                new FacilityPhoto { Id = 22, FacilityId = 5, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1786048406/terminba/facility_photos/mkrzxzvalq2kdz2xlfga.jpg", PublicId = "terminba/facility_photos/mkrzxzvalq2kdz2xlfga" },
                new FacilityPhoto { Id = 23, FacilityId = 6, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1786048406/terminba/facility_photos/mkrzxzvalq2kdz2xlfga.jpg", PublicId = "terminba/facility_photos/mkrzxzvalq2kdz2xlfga" },
                new FacilityPhoto { Id = 24, FacilityId = 7, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514237/generic_facility_court_6.jpg", PublicId = "generic_facility_court_6" },
                new FacilityPhoto { Id = 25, FacilityId = 8, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787515289/generic_football_facility_court_2.jpg", PublicId = "generic_football_facility_court_2" },
                new FacilityPhoto { Id = 26, FacilityId = 9, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514239/generic_facility_court_2.jpg", PublicId = "generic_facility_court_2" },
                new FacilityPhoto { Id = 27, FacilityId = 10, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787515289/generic_football_facility_court_4.jpg", PublicId = "generic_football_facility_court_4" },
                new FacilityPhoto { Id = 28, FacilityId = 11, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787515289/generic_football_facility_court_2.jpg", PublicId = "generic_football_facility_court_2" },
                new FacilityPhoto { Id = 29, FacilityId = 12, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514595/generic_tennis_facility_court_2.jpg", PublicId = "generic_tennis_facility_court_2" },
                new FacilityPhoto { Id = 30, FacilityId = 13, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514595/generic_tennis_facility_court_2.jpg", PublicId = "generic_tennis_facility_court_2" },
                new FacilityPhoto { Id = 31, FacilityId = 14, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514595/generic_tennis_facility_court_2.jpg", PublicId = "generic_tennis_facility_court_2" },
                new FacilityPhoto { Id = 32, FacilityId = 15, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514239/generic_facility_court_4.jpg", PublicId = "generic_facility_court_4" },
                new FacilityPhoto { Id = 33, FacilityId = 16, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787500869/ramiz_salcin_sala_2.jpg", PublicId = "ramiz_salcin_sala_2" },
                new FacilityPhoto { Id = 34, FacilityId = 17, Url = "hhttps://res.cloudinary.com/dtzupltuu/image/upload/v1787500869/ramiz_salcin_sala_2.jpg", PublicId = "ramiz_salcin_sala_2" },
                
                // 3rd photo for a few facilities
                new FacilityPhoto { Id = 35, FacilityId = 1, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787510604/stadion_grbavica_teren_3.jpg", PublicId = "stadion_grbavica_teren_3" },
                new FacilityPhoto { Id = 36, FacilityId = 2, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514242/generic_facility_court_1.jpg", PublicId = "generic_facility_court_1" },
                new FacilityPhoto { Id = 37, FacilityId = 3, Url = "https://res.cloudinary.com/dtzupltuu/image/upload/v1787514594/generic_tennis_facility_court_1.jpg", PublicId = "generic_tennis_facility_court_1" }
            );
        }

        // ── Helpers ──────────────────────────────────────────────────────────

        private User MakeUser(int id, string firstName, string lastName, string email,
            string phoneNumber, int roleId, int cityId, DateOnly birthDate, DateTime createdAt, string username = null)
        {
            var salt = "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=";
            var hash = HashingHelper.GenerateHash(salt, plainPassword);

            return new User
            {
                Id           = id,              
                FirstName    = firstName,
                LastName     = lastName,
                Email        = email,
                PhoneNumber  = phoneNumber,
                Username     = username ?? email.Split('@')[0],
                PasswordSalt = salt,
                PasswordHash = hash,
                RoleId       = roleId,
                CityId       = cityId,
                BirthDate    = birthDate,
                CreatedAt    = createdAt,
                UpdatedAt    = createdAt
            };
        }

        private SportCenter MakeSportCenter(
            int id,
            string displayName,
            string address,
            string phoneNumber,
            int roleId,
            int cityId,
            bool isEquipmentProvided,
            string description,
            DateTime createdAt,
            decimal latitude,
            decimal longitude)
        {
            var salt = "8B/80a0tP2L4/w0k4/4qJ+s2x+0zO5R+jQ4aM+q8t3g=";
            var hash = HashingHelper.GenerateHash(salt, plainPassword);

            string username = displayName
                .Trim()
                .ToLower()
                .Replace(" ", "_")
                .Replace("-", "_");

            return new SportCenter
            {
                Id = id,
                Username = username,
                DisplayName = displayName,
                PhoneNumber = phoneNumber,
                PasswordSalt = salt,
                PasswordHash = hash,
                RoleId = roleId,
                CityId = cityId,
                Address = address,
                IsEquipmentProvided = isEquipmentProvided,
                Description = description,
                Latitude = latitude,
                Longitude = longitude,
                CreatedAt = createdAt
            };
        }

        private static string GetReservationStatus(DateOnly reservationDate, DateOnly currentDate)
        {
            return reservationDate < currentDate
                ? nameof(CompletedReservationState)
                : nameof(ActiveReservationState);
        }

        private static bool IsReservationCompleted(DateOnly reservationDate, DateOnly currentDate)
        {
            return reservationDate < currentDate;
        }

        private static string GetPlayRequestState(
            DateOnly reservationDate,
            DateOnly currentDate,
            int numberOfPlayersWanted,
            int numberOfPlayersFound,
            int requestIndex)
        {
            bool reservationCompleted = IsReservationCompleted(reservationDate, currentDate);
            bool postIsFull = numberOfPlayersFound >= numberOfPlayersWanted;

            if (reservationCompleted && requestIndex % 4 == 3)
            {
                return nameof(ExpiredPlayRequestState);
            }

            if (postIsFull)
            {
                return requestIndex % 2 == 0
                    ? nameof(RejectedPlayRequestState)
                    : nameof(CanceledPlayRequestState);
            }

            return (requestIndex % 3) switch
            {
                0 => nameof(AcceptedPlayRequestState),
                1 => nameof(RejectedPlayRequestState),
                _ => nameof(CanceledPlayRequestState)
            };
        }  

        private static string GetPostState(
            DateOnly reservationDate,
             DateOnly currentDate,
            int numberOfPlayersWanted,
            int numberOfPlayersFound)
        {
            if (IsReservationCompleted(reservationDate, currentDate))
            {
                return nameof(FinishedPostState);
            }

            return numberOfPlayersFound >= numberOfPlayersWanted
                ? nameof(PlayerFoundPostState)
                : nameof(PlayerSearchPostState);
        }

        private static void SeedCancelationNotifications(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<CancelationNotification>().HasData(
                new CancelationNotification
                {
                    Id = 1,
                    PostOwnerId = 2,
                    ReservationId = 31,
                    RequesterName = "User 4",
                    FacilityName = "Basketball Court 1",
                    DateCancelled = new DateTime(2026, 5, 26, 10, 0, 0, DateTimeKind.Utc),
                    IsSeen = true
                },
                new CancelationNotification
                {
                    Id = 2,
                    PostOwnerId = 2,
                    ReservationId = 34,
                    RequesterName = "User 3",
                    FacilityName = "Basketball Court 1",
                    DateCancelled = new DateTime(2026, 6, 16, 10, 0, 0, DateTimeKind.Utc),
                    IsSeen = false
                }
            );
        }

    }
}
