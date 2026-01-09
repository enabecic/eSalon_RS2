using eSalon.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eSalon.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReportController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportController(IReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpGet("frizer-statistika-pdf")]
        [Authorize(Roles = "Frizer")] 
        public async Task<IActionResult> FrizerStatistika([FromQuery] string? stateMachine)
        {
            try
            {
                var pdf = await _reportService.FrizerStatistikaPdf(stateMachine);

                return File(
                    pdf,
                    "application/pdf",
                    $"FrizerStatistika_{DateTime.Now:yyyyMMdd_HHmmss}.pdf"
                );
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("admin-statistika-pdf")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AdminStatistika([FromQuery] string? stateMachine)
        {
            try
            {
                var pdf = await _reportService.AdminStatistikaPdf(stateMachine);

                return File(
                    pdf,
                    "application/pdf",
                    $"AdminStatistika_{DateTime.Now:yyyyMMdd_HHmmss}.pdf"
                );
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("frizer-kreiran-pdf")]
        public async Task<IActionResult> FrizerKreiranPdf([FromQuery] int frizerId,[FromQuery] string plainPassword)
        {
            try
            {
                var pdf = await _reportService.FrizerKreiranPdf(frizerId, plainPassword);

                return File(pdf, "application/pdf",
                    $"Frizer_{frizerId}_{DateTime.Now:yyyyMMddHHmm}.pdf");
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

    }
}
