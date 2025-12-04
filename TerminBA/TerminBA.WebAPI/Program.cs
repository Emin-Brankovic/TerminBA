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

Env.Load();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.RequireHttpsMetadata = false;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["JWTSecretKey"]!)),
            ValidateIssuer = false,
            ValidateAudience = false,
            ClockSkew = TimeSpan.Zero

        };
    });
builder.Services.AddAuthorization();

var app = builder.Build();




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
