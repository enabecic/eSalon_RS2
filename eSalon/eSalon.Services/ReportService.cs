using eSalon.Model.Exceptions;
using eSalon.Services.Database;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services
{
    public class ReportService : IReportService
    {
        private readonly ESalonContext _context;

        public ReportService(ESalonContext context)
        {
            _context = context;
        }

        public async Task<byte[]> FrizerStatistikaPdf(string? stateMachineFilter = null)
        {
            int ukupno = await _context.Rezervacijas
                .Where(r => !r.IsDeleted)
                .CountAsync();

            int zavrsene = await _context.Rezervacijas
                .Where(r => !r.IsDeleted && r.StateMachine != null && r.StateMachine.ToLower() == "zavrsena")
                .CountAsync();

            int otkazane = await _context.Rezervacijas
                .Where(r => !r.IsDeleted && r.StateMachine != null && r.StateMachine.ToLower() == "ponistena")
                .CountAsync();

            var mjeseci = new int[12]; 

            var query = _context.Rezervacijas.Where(r => !r.IsDeleted).AsQueryable();

            if (!string.IsNullOrWhiteSpace(stateMachineFilter))
            {
                query = query.Where(r => r.StateMachine != null && r.StateMachine.ToLower() == stateMachineFilter.ToLower());
            }

            var rezervacijePoMjesecima = await query
                .GroupBy(r => r.DatumRezervacije.Month)
                .Select(g => new { Mjesec = g.Key, Broj = g.Count() })
                .ToListAsync();

            foreach (var r in rezervacijePoMjesecima)
            {
                mjeseci[r.Mjesec - 1] = r.Broj;
            }

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(40);

                    page.Header()
                        .PaddingBottom(30)
                        .Text("Frizer izvještaj sistema")
                        .FontSize(22)
                        .SemiBold()
                        .FontColor(Colors.DeepPurple.Medium)
                        .AlignCenter();

                    page.Content().Column(col =>
                    {
                        col.Spacing(10);

                        col.Item().Row(row =>
                        {
                            void Card(Action<IContainer> build) =>
                                row.RelativeItem()
                                   .Padding(12)
                                   .Background(Colors.Grey.Lighten4)
                                   .MinHeight(70)
                                   .AlignMiddle()
                                   .AlignCenter()
                                   .Element(build);

                            Card(c => c
                                .AlignCenter()
                                .AlignMiddle()
                                .Column(col =>
                                {
                                    col.Item().Text("Ukupan broj rezervacija")
                                        .FontSize(11)
                                        .AlignCenter();

                                    col.Item().Text(ukupno.ToString())
                                        .FontSize(16)
                                        .SemiBold()
                                        .FontColor(Colors.DeepPurple.Medium)
                                        .AlignCenter();
                                })
                            );

                            Card(c => c
                                .AlignCenter()
                                .AlignMiddle()
                                .Column(col =>
                                {
                                    col.Item().Text("Ukupan broj završenih rezervacija")
                                        .FontSize(11)
                                        .AlignCenter();

                                    col.Item().Text(zavrsene.ToString())
                                        .FontSize(16)
                                        .SemiBold()
                                        .FontColor(Colors.DeepPurple.Medium)
                                        .AlignCenter();
                                })
                            );

                            Card(c => c
                                .AlignCenter()
                                .AlignMiddle()
                                .Column(col =>
                                {
                                    col.Item().Text("Ukupan broj otkazanih rezervacija")
                                        .FontSize(11)
                                        .AlignCenter();

                                    col.Item().Text(otkazane.ToString())
                                        .FontSize(16)
                                        .SemiBold()
                                        .FontColor(Colors.DeepPurple.Medium)
                                        .AlignCenter();
                                })
                            );
                        });

                        col.Item().Padding(2);

                        col.Item().Text(stateMachineFilter == null
                                        ? "Filtrirano po stanju: Sve rezervacije"
                                        : $"Filtrirano po stanju: {stateMachineFilter[0].ToString().ToUpper()}{stateMachineFilter.Substring(1)}")
                            .FontSize(12)
                            .FontColor(Colors.Grey.Darken2);

                        col.Item().Padding(1);

                        col.Item().Text("Broj rezervacija po mjesecima")
                            .FontSize(14).Bold();

                        col.Item().Table(table =>
                        {
                            table.ColumnsDefinition(cd =>
                            {
                                cd.RelativeColumn(2);
                                cd.RelativeColumn();
                            });

                            table.Header(header =>
                            {
                                header.Cell().Background(Colors.DeepPurple.Lighten2).Padding(5)
                                    .Text("Mjesec").FontColor(Colors.Black);
                                header.Cell().Background(Colors.DeepPurple.Lighten2).Padding(5)
                                    .AlignRight().Text("Broj rezervacija").FontColor(Colors.Black);
                            });

                            string[] mjeseciNazivi = { "Jan", "Feb", "Mar", "Apr", "Maj", "Jun", "Jul", "Avg", "Sep", "Okt", "Nov", "Dec" };
                            for (int i = 0; i < 12; i++)
                            {
                                table.Cell().Padding(5).Text(mjeseciNazivi[i]);
                                table.Cell().Padding(5).AlignRight().Text(mjeseci[i].ToString());
                            }
                        });

                        int ukupanBrojFilter = mjeseci.Sum();
                        col.Item().PaddingTop(1); 
                        col.Item().Text(stateMachineFilter == null
                                        ? $"Ukupan broj svih rezervacija: {ukupanBrojFilter}"
                                        : $"Ukupan broj rezervacija po filteru {stateMachineFilter}: {ukupanBrojFilter}")
                            .FontSize(12)
                            .FontColor(Colors.Grey.Darken2)
                            .AlignRight();

                    });

                    page.Footer().AlignCenter().Text(text =>
                    {
                        text.CurrentPageNumber();
                        text.Span("/");
                        text.TotalPages()
                            .FontSize(10)
                            .FontColor(Colors.Grey.Darken1);
                    });
                });
            });

            return document.GeneratePdf();
        }

        public async Task<byte[]> AdminStatistikaPdf(string? stateMachineFilter = null)
        {
            int brojKorisnika = await _context.Korisniks
                .Where(k => !k.IsDeleted)
                .CountAsync();

            int ukupnoRezervcaija = await _context.Rezervacijas
                .Where(r => !r.IsDeleted)
                .CountAsync();

            int brojOtkazanih = await _context.Rezervacijas
                .Where(r => !r.IsDeleted && r.StateMachine != null && r.StateMachine.ToLower() == "ponistena")
                .CountAsync();

            double stopaOtkaza = ukupnoRezervcaija > 0
                ? (double)brojOtkazanih / ukupnoRezervcaija * 100
                : 0;
            int brojArhiviranihUsluga = await _context.Arhivas
                .Where(a => !a.IsDeleted && a.Usluga != null && !a.Usluga.IsDeleted)
                .CountAsync();

            int brojRecenzija = await _context.Recenzijas
                .Where(r => !r.IsDeleted)
                .CountAsync();

            int brojRecenzijaOdgovora = await _context.RecenzijaOdgovors
                .Where(r => !r.IsDeleted)
                .CountAsync();

            int ukupanBrojRecenzija = brojRecenzija + brojRecenzijaOdgovora;

            var najtrazenijaUsluga = await _context.StavkeRezervacijes
                .Where(s => s.Rezervacija != null
                            && !s.Rezervacija.IsDeleted
                            && s.Rezervacija.StateMachine != "ponistena"
                            && s.Usluga != null
                            && !s.Usluga.IsDeleted)
                .GroupBy(s => s.Usluga.Naziv)
                .Select(g => new { Naziv = g.Key, Broj = g.Count() })
                .OrderByDescending(x => x.Broj)
                .FirstOrDefaultAsync();

            string nazivNajtrazenijeUsluge = najtrazenijaUsluga?.Naziv ?? "Nema podataka";

            var mjeseci = new int[12];

            var query = _context.Rezervacijas.Where(r => !r.IsDeleted).AsQueryable();

            if (!string.IsNullOrWhiteSpace(stateMachineFilter))
            {
                query = query.Where(r => r.StateMachine != null && r.StateMachine.ToLower() == stateMachineFilter.ToLower());
            }

            var rezervacijePoMjesecima = await query
                .GroupBy(r => r.DatumRezervacije.Month)
                .Select(g => new { Mjesec = g.Key, Broj = g.Count() })
                .ToListAsync();

            foreach (var r in rezervacijePoMjesecima)
            {
                mjeseci[r.Mjesec - 1] = r.Broj;
            }

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(40);

                    page.Header()
                        .PaddingBottom(30)
                        .Text("Admin izvještaj sistema")
                        .FontSize(22)
                        .SemiBold()
                        .FontColor(Colors.DeepPurple.Medium)
                        .AlignCenter();

                    page.Content().Column(col =>
                    {
                        col.Spacing(10);

                        col.Item().Row(row =>
                        {
                            row.Spacing(10);

                            void Card(Action<IContainer> build) =>
                                row.RelativeItem()
                                   .Padding(12)
                                   .Background(Colors.Grey.Lighten4)
                                   .MinHeight(70)
                                   .AlignMiddle()
                                   .AlignCenter()
                                   .Element(build);

                            Card(c => c.Column(col =>
                            {
                                col.Item().Text("Broj korisnika aplikacije").FontSize(11).AlignCenter();
                                col.Item().Text(brojKorisnika.ToString()).FontSize(16).SemiBold().AlignCenter().FontColor(Colors.DeepPurple.Medium);
                            }));

                            Card(c => c.Column(col =>
                            {
                                col.Item().Text("Stopa otkazanih rezervacija").FontSize(11).AlignCenter();
                                col.Item().Text($"{stopaOtkaza:F1}%").FontSize(16).SemiBold().AlignCenter().FontColor(Colors.DeepPurple.Medium);
                            }));

                            Card(c => c.Column(col =>
                            {
                                col.Item().Text("Ukupan broj rezervacija").FontSize(11).AlignCenter();
                                col.Item().Text(ukupnoRezervcaija.ToString()).FontSize(16).SemiBold().AlignCenter().FontColor(Colors.DeepPurple.Medium);
                            }));
                        });

                        col.Item().Row(row =>
                        {
                            row.Spacing(10);

                            void Card(Action<IContainer> build) =>
                                row.RelativeItem()
                                   .Padding(12)
                                   .Background(Colors.Grey.Lighten4)
                                   .MinHeight(70)
                                   .AlignMiddle()
                                   .AlignCenter()
                                   .Element(build);

                            Card(c => c.Column(col =>
                            {
                                col.Item().Text("Broj arhiviranih usluga").FontSize(11).AlignCenter();
                                col.Item().Text(brojArhiviranihUsluga.ToString()).FontSize(16).SemiBold().AlignCenter().FontColor(Colors.DeepPurple.Medium);
                            }));

                            Card(c => c.Column(col =>
                            {
                                col.Item().Text("Trenutno najtraženija usluga").FontSize(11).AlignCenter();
                                col.Item().Element(e =>
                                e.MaxWidth(120)
                                 .Text(nazivNajtrazenijeUsluge)
                                 .FontSize(12)
                                 .SemiBold()
                                 .AlignCenter()
                                 .FontColor(Colors.DeepPurple.Medium)
                            );
                            }));

                            Card(c => c.Column(col =>
                            {
                                col.Item().Text("Broj napisanih recenzija").FontSize(11).AlignCenter();
                                col.Item().Text(ukupanBrojRecenzija.ToString()).FontSize(16).SemiBold().AlignCenter().FontColor(Colors.DeepPurple.Medium);
                            }));
                        });

                        col.Item().Padding(2);

                        col.Item().Text(stateMachineFilter == null
                                        ? "Filtrirano po stanju: Sve rezervacije"
                                        : $"Filtrirano po stanju: {stateMachineFilter[0].ToString().ToUpper()}{stateMachineFilter.Substring(1)}")
                            .FontSize(12)
                            .FontColor(Colors.Grey.Darken2);

                        col.Item().Padding(1);

                        col.Item().Text("Broj rezervacija po mjesecima")
                            .FontSize(14).Bold();

                        col.Item().Table(table =>
                        {
                            table.ColumnsDefinition(cd =>
                            {
                                cd.RelativeColumn(2);
                                cd.RelativeColumn();
                            });

                            table.Header(header =>
                            {
                                header.Cell().Background(Colors.DeepPurple.Lighten2).Padding(5)
                                    .Text("Mjesec").FontColor(Colors.Black);
                                header.Cell().Background(Colors.DeepPurple.Lighten2).Padding(5)
                                    .AlignRight().Text("Broj rezervacija").FontColor(Colors.Black);
                            });

                            string[] mjeseciNazivi = { "Jan", "Feb", "Mar", "Apr", "Maj", "Jun", "Jul", "Avg", "Sep", "Okt", "Nov", "Dec" };
                            for (int i = 0; i < 12; i++)
                            {
                                table.Cell().Padding(5).Text(mjeseciNazivi[i]);
                                table.Cell().Padding(5).AlignRight().Text(mjeseci[i].ToString());
                            }
                        });
                        
                        int ukupanBrojFilter = mjeseci.Sum();
                        col.Item().PaddingTop(1);
                        col.Item().Text(stateMachineFilter == null
                                        ? $"Ukupan broj svih rezervacija: {ukupanBrojFilter}"
                                        : $"Ukupan broj rezervacija po filteru {stateMachineFilter}: {ukupanBrojFilter}")
                            .FontSize(12)
                            .FontColor(Colors.Grey.Darken2)
                            .AlignRight();
                    });

                    page.Footer().AlignCenter().Text(text =>
                    {
                        text.CurrentPageNumber();
                        text.Span("/");
                        text.TotalPages()
                            .FontSize(10)
                            .FontColor(Colors.Grey.Darken1);
                    });
                });
            });

            return document.GeneratePdf();
        }

        public async Task<byte[]> FrizerKreiranPdf(int frizerId, string plainPassword)
        {
            var frizer = await _context.Korisniks
            .Where(x => x.KorisnikId == frizerId && !x.IsDeleted)
            .Select(x => new
            {
                x.Ime,
                x.Prezime,
                x.Email,
                x.KorisnickoIme,
                x.DatumRegistracije
            })
            .FirstOrDefaultAsync();

            if (frizer == null)
                throw new UserException("Frizer nije pronađen.");

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(40);

                    page.Header().AlignCenter().Column(header =>
                    {
                        header.Spacing(5);

                        header.Item()
                            .PaddingBottom(10)
                            .PaddingTop(10)
                            .Text("Podaci o novom frizeru")
                            .FontSize(22)
                            .SemiBold()
                            .FontColor(Colors.DeepPurple.Medium);

                    });

                    page.Content().Column(col =>
                    {
                        col.Spacing(15);

                        void Line(string label, string value, bool bold = false)
                        {
                            col.Item()
                               .AlignCenter()
                               .Row(row =>
                               {
                                   var labelText = row.ConstantItem(180)
                                       .AlignRight()
                                       .Text(label)
                                       .FontSize(14);

                                   row.ConstantItem(20);

                                   var valueText = row.ConstantItem(200)
                                       .AlignLeft()
                                       .Text(value)
                                       .FontSize(14);

                                   if (bold)
                                   {
                                       labelText.SemiBold();
                                       valueText.SemiBold();
                                   }
                               });
                        }


                        col.Item().PaddingBottom(10);

                        Line("Ime:", frizer.Ime);
                        Line("Prezime:", frizer.Prezime);
                        Line("Email:", frizer.Email);
                        Line("Korisničko ime:", frizer.KorisnickoIme, true);
                        Line("Lozinka:", plainPassword, true);

                        col.Item().PaddingTop(20)
                            .LineHorizontal(1)
                            .LineColor(Colors.Grey.Lighten2);

                        col.Item()
                           .PaddingTop(20)
                           .AlignCenter()
                           .Text("Hvala što koristite naš sistem!")
                           .FontSize(17);

                        col.Item()
                           .PaddingTop(3)
                           .AlignCenter()
                           .Text("Molimo Vas da nakon prijave promijenite svoju lozinku.")
                           .FontSize(16)
                           .FontColor(Colors.Black);


                        col.Item().PaddingTop(20)
                            .LineHorizontal(1)
                            .LineColor(Colors.Grey.Lighten2);

                    });
                });
            });

            return document.GeneratePdf();
        }

    }
}
