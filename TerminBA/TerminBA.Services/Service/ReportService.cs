using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using TerminBA.Models.Enums;
using TerminBA.Models.Model;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;
using QuestPDF.Infrastructure;
using QuestPDF.Helpers;
using QuestPDF.Companion;

namespace TerminBA.Services.Service
{
    public class ReportService : IReportService
    {
        private readonly TerminBaContext _context;

        public ReportService(TerminBaContext context)
        {
            this._context = context;
            QuestPDF.Settings.License = QuestPDF.Infrastructure.LicenseType.Community;
        }

        public async Task<DashboardResponse> GetDashboard(int year)
        {
            var userCount = await _context.Users.CountAsync();
            var sportCenterCount = await _context.SportCenters.CountAsync();
            var reservationCount = await _context.Reservations.CountAsync();

            var userCountsByMonth = await _context.Users
                .Where(u => u.CreatedAt.Year == year)
                .GroupBy(u => u.CreatedAt.Month)
                .Select(g => new 
                {
                    Month = g.Key,
                    UserCount = g.Count()
                })
                .ToDictionaryAsync(x=>x.Month,x=>x.UserCount);


            var reservationCountByMonth = await _context.Reservations
                .Where(u => u.ReservationDate.Year == year)
                .GroupBy(u => u.ReservationDate.Month)
                .Select(g => new
                {
                    Month = g.Key,
                    UserCount = g.Count()
                })
                .ToDictionaryAsync(x => x.Month, x => x.UserCount);


            var response = new DashboardResponse
            {
                AppUserCount = userCount,
                AppReservationCount = reservationCount,
                AppSportCenterCount = sportCenterCount,
                UserCountByMonth = userCountsByMonth,
                ReservationCountByMonth = reservationCountByMonth,
            };


           return response;
        }

        public byte[] GetAdminReport(int totalUsers, int totalSportCenters, int totalReservations, int selectedYear, byte[] imageBytes)
        {
            var generatedAt = DateTime.Now;
            var reservationsPerCenter = totalSportCenters > 0
                ? (double)totalReservations / totalSportCenters
                : 0;
            var reservationsPerUser = totalUsers > 0
                ? (double)totalReservations / totalUsers
                : 0;

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(1.2f, Unit.Centimetre);
                    page.DefaultTextStyle(x => x.FontSize(11));

                    page.Header().Column(header =>
                    {
                        header.Item().Text("TerminBA Admin Report").FontSize(24).Bold();
                        header.Item().Text($"Reporting year: {selectedYear}").FontColor(Colors.Grey.Darken1);
                        header.Item().Text($"Generated: {generatedAt:yyyy-MM-dd HH:mm}").FontColor(Colors.Grey.Darken1);
                        header.Item().PaddingTop(8).LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                    });

                    page.Content().PaddingVertical(12).Column(col =>
                    {
                        col.Spacing(14);

                        col.Item().Text("Key Metrics").FontSize(16).SemiBold();
                        col.Item().Row(row =>
                        {
                            row.Spacing(10);
                            row.RelativeItem().Element(x => BuildMetricCard(x, "Total Users", totalUsers.ToString()));
                            row.RelativeItem().Element(x => BuildMetricCard(x, "Sport Centers", totalSportCenters.ToString()));
                            row.RelativeItem().Element(x => BuildMetricCard(x, "Reservations", totalReservations.ToString()));
                        });

                        col.Item().Text($"User and Reservation Charts ({selectedYear})").FontSize(16).SemiBold();
                        col.Item().Border(1).BorderColor(Colors.Grey.Lighten2).Padding(4).Column(chart =>
                        {
                            if (imageBytes != null && imageBytes.Length > 0)
                            {
                                chart.Item().Image(imageBytes).FitWidth();
                            }
                            else
                            {
                                chart.Item().Text("No chart image available for this report period.")
                                    .FontColor(Colors.Grey.Darken1)
                                    .Italic();
                            }
                        });

                        col.Item().Text("Insights").FontSize(16).SemiBold();
                        col.Item().Column(insights =>
                        {
                            insights.Spacing(4);
                            insights.Item().Text($"- Insights below summarize metrics for {selectedYear}.");
                            insights.Item().Text($"- Average reservations per sport center: {reservationsPerCenter:F2}");
                            insights.Item().Text($"- Average reservations per user: {reservationsPerUser:F2}");
                            insights.Item().Text(totalReservations > 0
                                ? "- Reservation activity is present and can be tracked by period on the chart above."
                                : "- No reservation activity was recorded for the selected period.");
                        });
                    });

                    page.Footer()
                        .AlignRight()
                        .Text($"TerminBA Report | {generatedAt:yyyy-MM-dd}")
                        .FontSize(9)
                        .FontColor(Colors.Grey.Darken1);
                });
            });

            return document.GeneratePdf();

            static IContainer BuildMetricCard(IContainer container, string title, string value)
            {
                var card = container
                    .Border(1)
                    .BorderColor(Colors.Grey.Lighten2)
                    .Background(Colors.Grey.Lighten5)
                    .Padding(10);

                card.Column(column =>
                {
                    column.Spacing(4);
                    column.Item().Text(title).FontColor(Colors.Grey.Darken1).SemiBold();
                    column.Item().Text(value).FontSize(20).Bold();
                });

                return card;
            }
        }


        public byte[] SportCenterCredentialsReport(string username, string password)
        {
            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(2, QuestPDF.Infrastructure.Unit.Centimetre);

                    page.Header()
                        .AlignCenter()
                        .Column(column =>
                        {
                            column.Spacing(0);

                            //Company Name
                            column.Item().AlignCenter().PaddingBottom(16).Text("TerminBA")
                                .FontSize(25)
                                .Bold();

                        });


                    page.Content()
                        .AlignCenter()
                        .Column(column =>
                        {
                            column.Spacing(15);

                            column.Item().AlignCenter().PaddingBottom(10).Width(350).LineHorizontal(2);

                            column.Item().AlignCenter().PaddingBottom(20).Text("Sport Center System Access Credentials")
                                .Bold()
                                .FontSize(20);


                            column.Item().AlignCenter().Table(table =>
                            {
                                table.ColumnsDefinition(columns =>
                                {
                                    columns.ConstantColumn(120); //Username Column 
                                    columns.ConstantColumn(120); //Password Column 
                                });

                                //Table Header
                                table.Header(header =>
                                {
                                    header.Cell().Background(Colors.LightBlue.Accent3).Border(1).AlignCenter().Text("Username").Bold();
                                    header.Cell().Background(Colors.LightBlue.Accent3).Border(1).AlignCenter().Text("Password").Bold();
                                });

                                //Table Rows 
                                table.Cell().Border(1).AlignCenter().Text(username);
                                table.Cell().Border(1).AlignCenter().Text(password);
                            });

                            //Warning message
                            column.Item().PaddingTop(20).AlignCenter().Text("Note that this password is temporary and you should change it immediately after receiving this document!").FontColor(Colors.Red.Medium)
                            .FontSize(10);
                        });

                    page.Footer()
                    .Column(column =>
                    {
                        column.Item()
                        .PaddingVertical(10)
                        .Text(text =>
                        {
                            text.Span("Page ");
                            text.CurrentPageNumber();
                            text.Span(" of ");
                            text.TotalPages();
                            text.AlignCenter();
                        });
                    });
                });
            });

            return document.GeneratePdf();
        }
    }
}
