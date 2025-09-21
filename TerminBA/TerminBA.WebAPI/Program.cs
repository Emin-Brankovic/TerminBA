using Mapster;
using Microsoft.EntityFrameworkCore;
using TerminBA.Services;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;
using TerminBA.Services.Service;


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

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddMapster();

var connectionString = builder.Configuration.GetConnectionString("db");
builder.Services.AddDbContext<TerminBaContext>(options =>
    options.UseSqlServer(connectionString));


var app = builder.Build();




// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
