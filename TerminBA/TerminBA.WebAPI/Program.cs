using DotNetEnv;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using TerminBA.Models.Execptions;
using TerminBA.Services;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;
using TerminBA.Services.PostStateMachine;
using TerminBA.Services.Service;
using TerminBA.WebAPI.Filters;


var builder = WebApplication.CreateBuilder(args);


builder.Services.AddTransient<ICityService, CityService>();
builder.Services.AddTransient<ISportService, SportService>();
builder.Services.AddTransient<IAmenityService, AmenityService>();
builder.Services.AddTransient<ITurfTypeService, TurfTypeService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IReservationService, ReservationService>();
builder.Services.AddTransient<IPostService, PostService>();
builder.Services.AddTransient<IWorkingHoursService, WorkingHoursService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<ISportCenterService,SportCenterService>();
builder.Services.AddTransient<IFacilityService, FacilityService>();
builder.Services.AddTransient<IFacilityReviewService, FacilityReviewService>();
builder.Services.AddTransient<IUserReviewService, UserReviewService>();
builder.Services.AddTransient<IPlayRequestService, PlayRequestService>();
builder.Services.AddScoped(typeof(IAuthService<>), typeof(AuthService<>));
builder.Services.AddTransient<IFacilityDynamicPriceService, FacilityDynamicPriceService>();
builder.Services.AddTransient<BasePostState>();
builder.Services.AddTransient<DraftPostState>();
builder.Services.AddTransient<PlayerSearchPostState>();
builder.Services.AddTransient<PlayerFoundPostState>();
builder.Services.AddTransient<ClosedPostState>();
builder.Services.AddTransient<EmailService>();


var rabbitHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
var rabbitUser = Environment.GetEnvironmentVariable("RABBITMQ_USER") ?? "guest";
var rabbitPass = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";

builder.Services.RegisterEasyNetQ($"host={rabbitHost};username={rabbitUser};password={rabbitPass}");



// Add services to the container.

builder.Services.AddControllers(x=>
    {
        x.Filters.Add<ExceptionFilter>();
    }
);
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference=new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] { }
        }
    });

});

// Configure Mapster mappings
builder.Services.AddMapster();

var connectionString = builder.Configuration.GetConnectionString("db");
builder.Services.AddDbContext<TerminBaContext>(options =>
    options.UseSqlServer(connectionString));

Env.Load("..\\.env");

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.RequireHttpsMetadata = false;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Environment.GetEnvironmentVariable("JWTSecretKey")!)),
            ValidateIssuer = false,
            ValidateAudience = false,
            ClockSkew = TimeSpan.Zero

        };
    });
builder.Services.AddAuthorization();

var app = builder.Build();


using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<TerminBaContext>();
    if (dataContext.Database.EnsureCreated())
    {
        dataContext.Database.Migrate();

        // Seed Roles
        dataContext.Roles.AddRange(
            new Role { RoleName = "Admin", RoleDescription = "Administrator with full system access" },
            new Role { RoleName = "User", RoleDescription = "Regular user who can make reservations" },
            new Role { RoleName = "SportCenterOwner", RoleDescription = "Owner of a sport center" },
            new Role { RoleName = "FacilityManager", RoleDescription = "Manager responsible for facility operations" }
        );

        // Seed Cities
        dataContext.Cities.AddRange(
            new City {Name = "Sarajevo" },
            new City {Name = "Banja Luka" },
            new City {Name = "Tuzla" },
            new City {Name = "Zenica" },
            new City {Name = "Mostar" },
            new City {Name = "Bijeljina" },
            new City {Name = "Prijedor" },
            new City {Name = "Doboj" }
        );

        // Seed Sports
        dataContext.Sports.AddRange(
            new Sport {SportName = "Football" },
            new Sport {SportName = "Basketball" },
            new Sport {SportName = "Tennis" },
            new Sport {SportName = "Volleyball" },
            new Sport {SportName = "Handball" },
            new Sport {SportName = "Badminton" },
            new Sport {SportName = "Table Tennis" }
        );

        // Seed TurfTypes
        dataContext.TurfTypes.AddRange(
            new TurfType {Name = "Natural Grass" },
            new TurfType {Name = "Artificial Grass" },
            new TurfType {Name = "Hard Court" },
            new TurfType {Name = "Clay" },
            new TurfType {Name = "Indoor" }
        );

        // Seed Amenities
        dataContext.Amenity.AddRange(
            new Amenity {Name = "Parking" },
            new Amenity {Name = "Locker Room" },
            new Amenity {Name = "Shower" },
            new Amenity {Name = "Cafeteria" },
            new Amenity {Name = "WiFi" },
            new Amenity {Name = "Lighting" },
            new Amenity {Name = "Equipment Rental" },
            new Amenity {Name = "First Aid" }
        );

        // Save changes to get IDs for foreign keys
        dataContext.SaveChanges();

        // Seed Users
        string plainPassword = "password";
        dataContext.Users.Add(CreateUser( "Korisnik", "Korisnik", "korisnik.korisnik@gmail.com", "+38761123456", plainPassword, 1, 1));
        dataContext.Users.Add(CreateUser( "Emin", "Branković", "emin.brankovic19@gmail.com", "+38761123456", plainPassword, 2, 1));
        dataContext.Users.Add(CreateUser( "Jasna", "Kovačević", "jasna.kovacevic@example.com", "+38761123457", plainPassword, 2, 2));
        dataContext.Users.Add(CreateUser( "Nermin", "Delić", "nermin.delic@example.com", "+38761123458", plainPassword, 2, 3));
        dataContext.Users.Add(CreateUser( "Ivana", "Jurić", "ivana.juric@example.com", "+38761123459", plainPassword, 2, 1));
        dataContext.Users.Add(CreateUser( "Adnan", "Begović", "adnan.begovic@example.com", "+38761123460", plainPassword, 2, 2));
        dataContext.Users.Add(CreateUser( "Lejla", "Halilović", "lejla.halilovic@example.com", "+38761123461", plainPassword, 2, 3));
        dataContext.Users.Add(CreateUser( "Haris", "Mujanović", "haris.mujanovic@example.com", "+38761123462", plainPassword, 3, 1));
        dataContext.Users.Add(CreateUser( "Selma", "Đurić", "selma.djuric@example.com", "+38761123463", plainPassword, 3, 2));
        dataContext.Users.Add(CreateUser("Emina", "Hasanović", "emina.hasanovic@example.com", "+38761123464", plainPassword, 2, 3));
        dataContext.Users.Add(CreateUser("Tarik", "Vuković", "tarik.vukovic@example.com", "+38761123465", plainPassword, 2, 1));

        dataContext.SaveChanges();

        // Seed SportCenters
        var sportCenter1 = CreateSportCenter("Stadion Grbavica", "Grbavica 1, Sarajevo", "stadion.grbavica", "+38761123470", plainPassword, 3, 1, true, "Premier football stadium with modern facilities");
        sportCenter1.AvailableSports = dataContext.Sports.Where(s => new[] { 1, 2 }.Contains(s.Id)).ToList();
        sportCenter1.AvailableAmenities = dataContext.Amenity.Where(a => new[] { 1, 2, 3, 4, 5, 6, 8 }.Contains(a.Id)).ToList();
        dataContext.SportCenters.Add(sportCenter1);

        var sportCenter2 = CreateSportCenter("Basketball Arena", "Centar, Banja Luka", "basketball.arena", "+38761123471", plainPassword, 3, 2, true, "Professional basketball court with indoor facilities");
        sportCenter2.AvailableSports = dataContext.Sports.Where(s => new[] { 2, 4, 5 }.Contains(s.Id)).ToList();
        sportCenter2.AvailableAmenities = dataContext.Amenity.Where(a => new[] { 1, 2, 3, 4, 5, 6, 7, 8 }.Contains(a.Id)).ToList();
        dataContext.SportCenters.Add(sportCenter2);

        var sportCenter3 = CreateSportCenter("Tennis Club Tuzla", "Slatina, Tuzla", "tennis.tuzla", "+38761123472", plainPassword, 3, 3, false, "Outdoor tennis courts with clay and hard court surfaces");
        sportCenter3.AvailableSports = dataContext.Sports.Where(s => new[] { 3, 6, 7 }.Contains(s.Id)).ToList();
        sportCenter3.AvailableAmenities = dataContext.Amenity.Where(a => new[] { 1, 2, 3, 4, 6, 7 }.Contains(a.Id)).ToList();
        dataContext.SportCenters.Add(sportCenter3);

        dataContext.SaveChanges();

        // Seed WorkingHours
        var today = DateOnly.FromDateTime(DateTime.Today);
        dataContext.WorkingHours.AddRange(
            new WorkingHours {SportCenterId = 1, StartDay = DayOfWeek.Monday, EndDay = DayOfWeek.Friday, OpeningHours = new TimeOnly(8, 0), CloseingHours = new TimeOnly(22, 0), ValidFrom = today, ValidTo = null },
            new WorkingHours {SportCenterId = 1, StartDay = DayOfWeek.Saturday, EndDay = DayOfWeek.Sunday, OpeningHours = new TimeOnly(9, 0), CloseingHours = new TimeOnly(20, 0), ValidFrom = today, ValidTo = null },
            new WorkingHours {SportCenterId = 2, StartDay = DayOfWeek.Monday, EndDay = DayOfWeek.Sunday, OpeningHours = new TimeOnly(7, 0), CloseingHours = new TimeOnly(23, 0), ValidFrom = today, ValidTo = null },
            new WorkingHours { SportCenterId = 3, StartDay = DayOfWeek.Monday, EndDay = DayOfWeek.Friday, OpeningHours = new TimeOnly(6, 0), CloseingHours = new TimeOnly(21, 0), ValidFrom = today, ValidTo = null },
            new WorkingHours { SportCenterId = 3, StartDay = DayOfWeek.Saturday, EndDay = DayOfWeek.Sunday, OpeningHours = new TimeOnly(8, 0), CloseingHours = new TimeOnly(19, 0), ValidFrom = today, ValidTo = null }
        );

        dataContext.SaveChanges();

        // Seed Facilities
        var facility1 = new Facility
        {
            Name = "Main Football Field",
            MaxCapacity = 22,
            IsDynamicPricing = true,
            StaticPrice = null,
            IsIndoor = false,
            Duration = TimeSpan.FromHours(1.5),
            SportCenterId = 1,
            TurfTypeId = 2,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        facility1.AvailableSports = dataContext.Sports.Where(s => s.Id == 1).ToList();
        dataContext.Facilities.Add(facility1);

        var facility2 = new Facility
        {
            Name = "Basketball Court A",
            MaxCapacity = 10,
            IsDynamicPricing = false,
            StaticPrice = 50.00m,
            IsIndoor = true,
            Duration = TimeSpan.FromHours(1),
            SportCenterId = 2,
            TurfTypeId = 5,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        facility2.AvailableSports = dataContext.Sports.Where(s => s.Id == 2).ToList();
        dataContext.Facilities.Add(facility2);

        var facility3 = new Facility
        {
            Name = "Tennis Court 1",
            MaxCapacity = 4,
            IsDynamicPricing = true,
            StaticPrice = null,
            IsIndoor = false,
            Duration = TimeSpan.FromHours(1),
            SportCenterId = 3,
            TurfTypeId = 4,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        facility3.AvailableSports = dataContext.Sports.Where(s => s.Id == 3).ToList();
        dataContext.Facilities.Add(facility3);

        var facility4 = new Facility
        {
            Name = "Volleyball Court",
            MaxCapacity = 12,
            IsDynamicPricing = false,
            StaticPrice = 40.00m,
            IsIndoor = true,
            Duration = TimeSpan.FromHours(1.5),
            SportCenterId = 2,
            TurfTypeId = 5,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        facility4.AvailableSports = dataContext.Sports.Where(s => s.Id == 4).ToList();
        dataContext.Facilities.Add(facility4);

        dataContext.SaveChanges();

        // Seed FacilityDynamicPrices
        dataContext.FacilityDynamicPrices.AddRange(
            new FacilityDynamicPrice {FacilityId = 1, StartDay = DayOfWeek.Monday, EndDay = DayOfWeek.Friday, StartTime = new TimeOnly(8, 0), EndTime = new TimeOnly(17, 0), PricePerHour = 60.00m, ValidFrom = today, ValidTo = null },
            new FacilityDynamicPrice {FacilityId = 1, StartDay = DayOfWeek.Monday, EndDay = DayOfWeek.Friday, StartTime = new TimeOnly(17, 0), EndTime = new TimeOnly(22, 0), PricePerHour = 80.00m, ValidFrom = today, ValidTo = null },
            new FacilityDynamicPrice {FacilityId = 1, StartDay = DayOfWeek.Saturday, EndDay = DayOfWeek.Sunday, StartTime = new TimeOnly(9, 0), EndTime = new TimeOnly(20, 0), PricePerHour = 90.00m, ValidFrom = today, ValidTo = null },
            new FacilityDynamicPrice {FacilityId = 3, StartDay = DayOfWeek.Monday, EndDay = DayOfWeek.Friday, StartTime = new TimeOnly(6, 0), EndTime = new TimeOnly(18, 0), PricePerHour = 45.00m, ValidFrom = today, ValidTo = null },
            new FacilityDynamicPrice {FacilityId = 3, StartDay = DayOfWeek.Saturday, EndDay = DayOfWeek.Sunday, StartTime = new TimeOnly(8, 0), EndTime = new TimeOnly(19, 0), PricePerHour = 55.00m, ValidFrom = today, ValidTo = null }
        );

        dataContext.SaveChanges();

        // Seed Reservations
        var reservationDate1 = DateOnly.FromDateTime(DateTime.Today.AddDays(3));
        var reservationDate2 = DateOnly.FromDateTime(DateTime.Today.AddDays(5));
        var reservationDate3 = DateOnly.FromDateTime(DateTime.Today.AddDays(7));

        dataContext.Reservations.AddRange(
            new Reservation { UserId = 2, FacilityId = 1, ReservationDate = reservationDate1, StartTime = new TimeOnly(18, 0), EndTime = new TimeOnly(19, 30), Status = "Confirmed", Price = 120.00m, ChosenSportId = 1 },
            new Reservation { UserId = 3, FacilityId = 2, ReservationDate = reservationDate1, StartTime = new TimeOnly(19, 0), EndTime = new TimeOnly(20, 0), Status = "Confirmed", Price = 50.00m, ChosenSportId = 2 },
            new Reservation { UserId = 4, FacilityId = 3, ReservationDate = reservationDate2, StartTime = new TimeOnly(10, 0), EndTime = new TimeOnly(11, 0), Status = "Confirmed", Price = 45.00m, ChosenSportId = 3 },
            new Reservation { UserId = 5, FacilityId = 1, ReservationDate = reservationDate2, StartTime = new TimeOnly(20, 0), EndTime = new TimeOnly(21, 30), Status = "Confirmed", Price = 120.00m, ChosenSportId = 1 },
            new Reservation { UserId = 6, FacilityId = 4, ReservationDate = reservationDate3, StartTime = new TimeOnly(16, 0), EndTime = new TimeOnly(17, 30), Status = "Confirmed", Price = 60.00m, ChosenSportId = 4 },
            new Reservation { UserId = 7, FacilityId = 3, ReservationDate = reservationDate3, StartTime = new TimeOnly(14, 0), EndTime = new TimeOnly(15, 0), Status = "Confirmed", Price = 45.00m, ChosenSportId = 3 }
        );

        dataContext.SaveChanges();

        // Seed Posts
        dataContext.Posts.AddRange(
            new Post {SkillLevel = "Intermediate", NumberOfPlayersWanted = 3, NumberOfPlayersFound = 1, Text = "Looking for players for a friendly match", ReservationId = 1, PostState = "PlayerSearchPostState" },
            new Post {SkillLevel = "Beginner", NumberOfPlayersWanted = 2, NumberOfPlayersFound = 0, Text = "Need players for basketball game", ReservationId = 2, PostState = "PlayerSearchPostState" },
            new Post {SkillLevel = "Advanced", NumberOfPlayersWanted = 1, NumberOfPlayersFound = 1, Text = "Looking for a tennis partner", ReservationId = 3, PostState = "PlayerFoundPostState" },
            new Post {SkillLevel = "Intermediate", NumberOfPlayersWanted = 4, NumberOfPlayersFound = 2, Text = "Football match - need more players", ReservationId = 4, PostState = "PlayerSearchPostState" }
        );

        dataContext.SaveChanges();

        // Seed PlayRequests
        dataContext.PlayRequests.AddRange(
            new PlayRequest { PostId = 1, RequesterId = 10, isAccepted = true, RequestText = "I'd like to join your game", DateOfRequest = DateTime.UtcNow.AddDays(-2), DateOfResponse = DateTime.UtcNow.AddDays(-1) },
            new PlayRequest {PostId = 2, RequesterId = 11, isAccepted = null, RequestText = "Can I join?", DateOfRequest = DateTime.UtcNow.AddDays(-1) },
            new PlayRequest { PostId = 3, RequesterId = 2, isAccepted = true, RequestText = "I'm available for tennis", DateOfRequest = DateTime.UtcNow.AddDays(-3), DateOfResponse = DateTime.UtcNow.AddDays(-2) },
            new PlayRequest { PostId = 4, RequesterId = 3, isAccepted = true, RequestText = "Count me in for football", DateOfRequest = DateTime.UtcNow.AddDays(-2), DateOfResponse = DateTime.UtcNow.AddDays(-1) },
            new PlayRequest { PostId = 4, RequesterId = 6, isAccepted = true, RequestText = "I want to play", DateOfRequest = DateTime.UtcNow.AddDays(-1), DateOfResponse = DateTime.UtcNow }
        );

        dataContext.SaveChanges();

        //// Seed FacilityReviews
        //var reviewDate = DateOnly.FromDateTime(DateTime.Today.AddDays(-10));
        //dataContext.FacilityReviews.AddRange(
        //    new FacilityReview { Id = 1, RatingNumber = 5, RatingDate = reviewDate, Comment = "Excellent facility, well maintained", UserId = 2, FacilityId = 1 },
        //    new FacilityReview { Id = 2, RatingNumber = 4, RatingDate = reviewDate.AddDays(1), Comment = "Great court, good lighting", UserId = 3, FacilityId = 2 },
        //    new FacilityReview { Id = 3, RatingNumber = 5, RatingDate = reviewDate.AddDays(2), Comment = "Perfect tennis court", UserId = 4, FacilityId = 3 },
        //    new FacilityReview { Id = 4, RatingNumber = 4, RatingDate = reviewDate.AddDays(3), Comment = "Nice volleyball court", UserId = 5, FacilityId = 4 },
        //    new FacilityReview { Id = 5, RatingNumber = 3, RatingDate = reviewDate.AddDays(4), Comment = "Could be better maintained", UserId = 6, FacilityId = 1 }
        //);

        //dataContext.SaveChanges();

        //// Seed UserReviews
        //dataContext.UserReviews.AddRange(
        //    new UserReview { Id = 1, RatingNumber = 5, RatingDate = reviewDate, Comment = "Great player, very fair", ReviewerId = 2, ReviewedId = 10 },
        //    new UserReview { Id = 2, RatingNumber = 4, RatingDate = reviewDate.AddDays(1), Comment = "Good teammate", ReviewerId = 3, ReviewedId = 11 },
        //    new UserReview { Id = 3, RatingNumber = 5, RatingDate = reviewDate.AddDays(2), Comment = "Excellent sportsmanship", ReviewerId = 4, ReviewedId = 2 },
        //    new UserReview { Id = 4, RatingNumber = 4, RatingDate = reviewDate.AddDays(3), Comment = "Reliable player", ReviewerId = 5, ReviewedId = 3 },
        //    new UserReview { Id = 5, RatingNumber = 3, RatingDate = reviewDate.AddDays(4), Comment = "Average player", ReviewerId = 6, ReviewedId = 7 }
        //);

        //dataContext.SaveChanges();
    }
}

static User CreateUser(string firstName, string lastName, string email, string phoneNumber, string password, int roleId, int cityId)
{
    var salt = HashingHelper.GenerateSalt();
    var hash = HashingHelper.GenerateHash(salt, password);

    return new User
    {
        FirstName = firstName,
        LastName = lastName,
        Email = email,
        PhoneNumber = phoneNumber,
        Username = email.Split('@')[0],
        PasswordSalt = salt,
        PasswordHash = hash,
        RoleId = roleId,
        CityId = cityId,
        Age = 25,
        BirthDate = DateOnly.FromDateTime(DateTime.Now.AddYears(-25)),
        IsActive = true,
        CreatedAt = DateTime.UtcNow,
        UpdatedAt = DateTime.UtcNow
    };
}

static SportCenter CreateSportCenter(string name, string address, string username, string phoneNumber, string password, int roleId, int cityId, bool isEquipmentProvided, string description)
{
    var salt = HashingHelper.GenerateSalt();
    var hash = HashingHelper.GenerateHash(salt, password);

    return new SportCenter
    {
        Username = username,
        PhoneNumber = phoneNumber,
        PasswordSalt = salt,
        PasswordHash = hash,
        RoleId = roleId,
        CityId = cityId,
        Address = address,
        IsEquipmentProvided = isEquipmentProvided,
        Description = description,
        CreatedAt = DateTime.UtcNow
    };
}




// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();
