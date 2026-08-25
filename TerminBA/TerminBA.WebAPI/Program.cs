using DotNetEnv;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.ML;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using TerminBA.Models.Execptions;
using TerminBA.Services;
using TerminBA.Services.BackgroundServices;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;
using TerminBA.Services.PostStateMachine;
using TerminBA.Services.PlayRequestStateMachine;
using TerminBA.Services.Recommender;
using TerminBA.Services.ReservationStateMachine;
using TerminBA.Services.Service;
using TerminBA.WebAPI.Filters;


var builder = WebApplication.CreateBuilder(args);


builder.Services.AddScoped<ICityService, CityService>();
builder.Services.AddScoped<ISportService, SportService>();
builder.Services.AddScoped<IAmenityService, AmenityService>();
builder.Services.AddScoped<ITurfTypeService, TurfTypeService>();
builder.Services.AddScoped<IRoleService, RoleService>();
builder.Services.AddScoped<IReservationService, ReservationService>();
builder.Services.AddScoped<IPostService, PostService>();
builder.Services.AddScoped<IWorkingHoursService, WorkingHoursService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<ISportCenterService,SportCenterService>();
builder.Services.AddScoped<IFavoriteSportCenterService, FavoriteSportCenterService>();
builder.Services.AddScoped<IFacilityService, FacilityService>();
builder.Services.AddScoped<IFacilityReviewService, FacilityReviewService>();
builder.Services.AddScoped<IUserReviewService, UserReviewService>();
builder.Services.AddScoped<IPlayRequestService, PlayRequestService>();
builder.Services.AddScoped<ICancelationNotificationService, CancelationNotificationService>();
builder.Services.AddScoped(typeof(IAuthService<>), typeof(AuthService<>));
builder.Services.AddScoped<IFacilityDynamicPriceService, FacilityDynamicPriceService>();
//Post states
builder.Services.AddScoped<BasePostState>();
builder.Services.AddScoped<DraftPostState>();
builder.Services.AddScoped<PlayerSearchPostState>();
builder.Services.AddScoped<PlayerFoundPostState>();
builder.Services.AddScoped<ClosedPostState>();
builder.Services.AddScoped<FinishedPostState>();
builder.Services.AddScoped<CanceledReservationPostState>();
//Reservation states
builder.Services.AddScoped<BaseReservationState>();
builder.Services.AddScoped<ActiveReservationState>();
builder.Services.AddScoped<CanceledReservationState>();
builder.Services.AddScoped<PendingReservationState>();
builder.Services.AddScoped<CanceledWithRefundReservationState>();
builder.Services.AddScoped<CanceledWithoutRefundReservationState>();

builder.Services.AddTransient<EmailService>();
builder.Services.AddScoped<IReportService,ReportService>();
builder.Services.AddScoped<IPhotoService, PhotoService>();
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<CompletedReservationState>();
builder.Services.AddHostedService<ReservationCompletionHostedService>();
builder.Services.AddHostedService<RevokedTokenCleanupService>();
builder.Services.AddHostedService<RecommendationTrainingHostedService>();
builder.Services.AddSignalR();
builder.Services.AddScoped<INotificationsHubService, TerminBA.WebAPI.Hubs.NotificationsHubService>();

// PlayRequest State Machine
builder.Services.AddScoped<BasePlayRequestState>();
builder.Services.AddScoped<PendingPlayRequestState>();
builder.Services.AddScoped<AcceptedPlayRequestState>();
builder.Services.AddScoped<RejectedPlayRequestState>();
builder.Services.AddScoped<CanceledPlayRequestState>();
builder.Services.AddScoped<ExpiredPlayRequestState>();

// Stripe payment service (reads StripeSecretKey from env, secret stays server-side)
builder.Services.AddScoped<IStripePaymentService, StripePaymentService>();

// Geocoding
builder.Services.AddHttpClient<IGeocodingService, NominatimGeocodingService>(client =>
{
    client.DefaultRequestHeaders.UserAgent.ParseAdd("TerminBA/1.0 (sport center geocoding)");
    client.Timeout = TimeSpan.FromSeconds(10);
});

// ML.NET Recommendation — PredictionEnginePool is thread-safe and hot-reloads model.zip on save
builder.Services.AddPredictionEnginePool<RecommendationInput, RecommendationPrediction>()
    .FromFile(modelName: "RecommenderModel", filePath: "MLModels/model.zip", watchForChanges: true);

builder.Services.AddScoped<IRecommendationService, RecommendationService>();



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
        options.Events = new JwtBearerEvents
        {
            OnTokenValidated = async context =>
            {
                var jti = context.Principal?.FindFirst("jti")?.Value;
                if (string.IsNullOrEmpty(jti))
                    return;

                var dbContext = context.HttpContext.RequestServices
                    .GetRequiredService<TerminBaContext>();

                var isRevoked = await dbContext.RevokedTokens
                    .AnyAsync(rt => rt.Jti == jti);

                if (isRevoked)
                    context.Fail("Token has been revoked.");
            }
        };
    });
builder.Services.AddAuthorization();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<TerminBaContext>();
    dataContext.Database.Migrate();
}


// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors("AllowAll");

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();
app.MapHub<TerminBA.WebAPI.Hubs.NotificationsHub>("/notificationsHub");

app.Run();
