using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Metadata.Conventions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

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
        private readonly ICityService cityService;
        private readonly IReportService reportService;

        public WeatherForecastController(ILogger<WeatherForecastController> logger,TerminBaContext context, ICityService cityService, IReportService reportService)
        {
            _logger = logger;
            _context = context;
            this.cityService = cityService;
            this.reportService = reportService;
        }

        [HttpGet]
        public IActionResult Get()
        {
            this.reportService.SportCenterCredentialsReport("skenderija", "password");
                
            return Ok();
        }

    }
}
