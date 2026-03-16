using EasyNetQ;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Reflection.Metadata.Ecma335;
using TerminBA.Models.Model;
using TerminBA.Services.Interfaces;

namespace TerminBA.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReportController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportController(IReportService reportService)
        {
            this._reportService = reportService;
        }

        [HttpGet("{year}")]
        [Authorize(Roles = "Administrator")]
        public async Task<DashboardResponse> GetDashboardData(int year)
        {
            return await _reportService.GetDashboard(year);
        }

        [HttpPost("generate")]
        [Authorize(Roles = "Administrator")]
        public async Task<IActionResult> GenerateAdminReport(
        IFormFile chartImage, 
        [FromForm] int totalUsers,
        [FromForm] int totalSportCenters,
        [FromForm] int totalReservations,
        [FromForm] int selectedYear)
        {
            if (chartImage == null || chartImage.Length == 0)
                return BadRequest("No image uploaded");

            byte[] imageBytes;
            using (var memoryStream = new MemoryStream())
            {
                await chartImage.CopyToAsync(memoryStream);
                imageBytes = memoryStream.ToArray();

            }

            byte[] pdfBytes = _reportService.GetAdminReport(totalUsers,totalSportCenters,totalReservations,selectedYear,imageBytes);

            return File(pdfBytes, "application/pdf", $"{DateTime.Now.ToString("dd.MM.yyyy")}-report.pdf");
        }
    }
}
