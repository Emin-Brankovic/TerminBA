using Microsoft.AspNetCore.Mvc;
using TerminBA.Services.Database;

namespace TerminBA.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        private readonly ILogger<WeatherForecastController> _logger;
        private readonly TerminBaContext _context;

        public WeatherForecastController(ILogger<WeatherForecastController> logger,TerminBaContext context)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet(Name = "GetCities")]
        public List<City> GetCities()
        {
            return _context.Cities.ToList();
        }
    }
}
