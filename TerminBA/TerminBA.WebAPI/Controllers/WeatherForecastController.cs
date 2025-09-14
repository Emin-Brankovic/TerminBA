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

        public WeatherForecastController(ILogger<WeatherForecastController> logger,TerminBaContext context, ICityService cityService)
        {
            _logger = logger;
            _context = context;
            this.cityService = cityService;
        }

        [HttpGet(Name = "GetCities")]
        public async Task<PagedResult<CityResponse>> GetCities([FromQuery] CitySearchObject searchObject)
        {
            return await cityService.GetAsync(searchObject);
        }

        [HttpGet("GetCity/{id}")]
        public async Task<ActionResult<CityResponse>> GetCityById(int id)
        {
            var city = await cityService.GetByIdAsync(id);

            if (city == null)
                return BadRequest();

            return city;
        }

        [HttpPost("CreateCity")]
        public async Task<ActionResult<CityResponse>> AddCity([FromBody] CityInsertRequest request)
        {
            var city = await cityService.CreateAsync(request);

            if (city == null)
                return BadRequest();

            return city;
        }

        [HttpPut("UpdateCity/{id}")]
        public async Task<ActionResult<CityResponse>> UpdateCity(int id,[FromBody] CityUpdateRequest request)
        {
            var city = await cityService.UpdateAsync(id,request);

            if (city == null)
                return BadRequest();

            return city;
        }

        [HttpDelete("DeleteCity/{id}")]
        public async Task<ActionResult<bool>> DeleteCity(int id)
        {
            var response = await cityService.DeleteAsync(id);

            if (!response)
                return BadRequest();

            return response;
        }
    }
}
