using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eSalon.Services.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Korisnik",
                columns: table => new
                {
                    KorisnikId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Ime = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Prezime = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    KorisnickoIme = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Telefon = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    Slika = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    LozinkaHash = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    LozinkaSalt = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    JeAktivan = table.Column<bool>(type: "bit", nullable: true, defaultValueSql: "((1))"),
                    DatumRegistracije = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Korisnik__80B06D41D5A05C3E", x => x.KorisnikId);
                });

            migrationBuilder.CreateTable(
                name: "NacinPlacanja",
                columns: table => new
                {
                    NacinPlacanjaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__NacinPla__AD0C4729CEFE554B", x => x.NacinPlacanjaId);
                });

            migrationBuilder.CreateTable(
                name: "Uloga",
                columns: table => new
                {
                    UlogaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Opis = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Uloga__DCAB23CB8D8DBCEC", x => x.UlogaId);
                });

            migrationBuilder.CreateTable(
                name: "VrstaUsluge",
                columns: table => new
                {
                    VrstaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Slika = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__VrstaUsl__42CB8F2F695BF2C1", x => x.VrstaId);
                });

            migrationBuilder.CreateTable(
                name: "Obavijest",
                columns: table => new
                {
                    ObavijestId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    Naslov = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Sadrzaj = table.Column<string>(type: "text", nullable: false),
                    DatumObavijesti = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    JePogledana = table.Column<bool>(type: "bit", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Obavijes__99D330E0E1DFA3E0", x => x.ObavijestId);
                    table.ForeignKey(
                        name: "FK__Obavijest__Koris__4F7CD00D",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                });

            migrationBuilder.CreateTable(
                name: "KorisniciUloge",
                columns: table => new
                {
                    KorisnikUlogaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    UlogaId = table.Column<int>(type: "int", nullable: false),
                    DatumDodavanja = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Korisnic__1608726E9F3DF1AD", x => x.KorisnikUlogaId);
                    table.ForeignKey(
                        name: "FK__Korisnici__Koris__412EB0B6",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Korisnici__Uloga__4222D4EF",
                        column: x => x.UlogaId,
                        principalTable: "Uloga",
                        principalColumn: "UlogaId");
                });

            migrationBuilder.CreateTable(
                name: "Usluga",
                columns: table => new
                {
                    UslugaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Opis = table.Column<string>(type: "text", nullable: true),
                    Cijena = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    Trajanje = table.Column<int>(type: "int", nullable: false),
                    Slika = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    DatumObjavljivanja = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    VrstaId = table.Column<int>(type: "int", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Usluga__0BE5E72F255F7E85", x => x.UslugaId);
                    table.ForeignKey(
                        name: "FK__Usluga__VrstaId__4BAC3F29",
                        column: x => x.VrstaId,
                        principalTable: "VrstaUsluge",
                        principalColumn: "VrstaId");
                });

            migrationBuilder.CreateTable(
                name: "Arhiva",
                columns: table => new
                {
                    ArhivaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    UslugaId = table.Column<int>(type: "int", nullable: false),
                    DatumDodavanja = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Arhiva__A791E50C258529DA", x => x.ArhivaId);
                    table.ForeignKey(
                        name: "FK__Arhiva__Korisnik__5AEE82B9",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Arhiva__UslugaId__5BE2A6F2",
                        column: x => x.UslugaId,
                        principalTable: "Usluga",
                        principalColumn: "UslugaId");
                });

            migrationBuilder.CreateTable(
                name: "Favorit",
                columns: table => new
                {
                    FavoritId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    UslugaId = table.Column<int>(type: "int", nullable: false),
                    DatumDodavanja = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Favorit__C32DB3CCB7D5AA77", x => x.FavoritId);
                    table.ForeignKey(
                        name: "FK__Favorit__Korisni__5535A963",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Favorit__UslugaI__5629CD9C",
                        column: x => x.UslugaId,
                        principalTable: "Usluga",
                        principalColumn: "UslugaId");
                });

            migrationBuilder.CreateTable(
                name: "Ocjena",
                columns: table => new
                {
                    OcjenaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UslugaId = table.Column<int>(type: "int", nullable: false),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    Vrijednost = table.Column<int>(type: "int", nullable: false),
                    DatumOcjenjivanja = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Ocjena__E6FC7AA94668F7DF", x => x.OcjenaId);
                    table.ForeignKey(
                        name: "FK__Ocjena__Korisnik__02084FDA",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Ocjena__UslugaId__01142BA1",
                        column: x => x.UslugaId,
                        principalTable: "Usluga",
                        principalColumn: "UslugaId");
                });

            migrationBuilder.CreateTable(
                name: "Promocija",
                columns: table => new
                {
                    PromocijaID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Opis = table.Column<string>(type: "text", nullable: true),
                    Kod = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Popust = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    DatumPocetka = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    DatumKraja = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    UslugaId = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<bool>(type: "bit", nullable: false, defaultValueSql: "((1))"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Promocij__2C5ACD714D0FD88B", x => x.PromocijaID);
                    table.ForeignKey(
                        name: "FK__Promocija__Uslug__66603565",
                        column: x => x.UslugaId,
                        principalTable: "Usluga",
                        principalColumn: "UslugaId");
                });

            migrationBuilder.CreateTable(
                name: "Recenzija",
                columns: table => new
                {
                    RecenzijaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    UslugaId = table.Column<int>(type: "int", nullable: false),
                    Komentar = table.Column<string>(type: "text", nullable: false),
                    DatumDodavanja = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    BrojLajkova = table.Column<int>(type: "int", nullable: true, defaultValueSql: "((0))"),
                    BrojDislajkova = table.Column<int>(type: "int", nullable: true, defaultValueSql: "((0))"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Recenzij__D36C60705E30AA70", x => x.RecenzijaId);
                    table.ForeignKey(
                        name: "FK__Recenzija__Koris__07C12930",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Recenzija__Uslug__08B54D69",
                        column: x => x.UslugaId,
                        principalTable: "Usluga",
                        principalColumn: "UslugaId");
                });

            migrationBuilder.CreateTable(
                name: "AktiviranaPromocija",
                columns: table => new
                {
                    AktiviranaPromocijaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PromocijaID = table.Column<int>(type: "int", nullable: false),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    Aktivirana = table.Column<bool>(type: "bit", nullable: false),
                    Iskoristena = table.Column<bool>(type: "bit", nullable: false),
                    DatumAktiviranja = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Aktivira__E44F1952AE21862C", x => x.AktiviranaPromocijaId);
                    table.ForeignKey(
                        name: "FK__Aktiviran__Koris__6C190EBB",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Aktiviran__Promo__6B24EA82",
                        column: x => x.PromocijaID,
                        principalTable: "Promocija",
                        principalColumn: "PromocijaID");
                });

            migrationBuilder.CreateTable(
                name: "RecenzijaOdgovor",
                columns: table => new
                {
                    RecenzijaOdgovorId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RecenzijaId = table.Column<int>(type: "int", nullable: false),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    Komentar = table.Column<string>(type: "text", nullable: false),
                    DatumDodavanja = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    BrojLajkova = table.Column<int>(type: "int", nullable: true, defaultValueSql: "((0))"),
                    BrojDislajkova = table.Column<int>(type: "int", nullable: true, defaultValueSql: "((0))"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Recenzij__23922A44E1A14A69", x => x.RecenzijaOdgovorId);
                    table.ForeignKey(
                        name: "FK__Recenzija__Koris__10566F31",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Recenzija__Recen__0F624AF8",
                        column: x => x.RecenzijaId,
                        principalTable: "Recenzija",
                        principalColumn: "RecenzijaId");
                });

            migrationBuilder.CreateTable(
                name: "RecenzijaReakcija",
                columns: table => new
                {
                    RecenzijaReakcijaId = table.Column<int>(type: "int", nullable: false),
                    RecenzijaId = table.Column<int>(type: "int", nullable: false),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    JeLajk = table.Column<bool>(type: "bit", nullable: false),
                    DatumReakcije = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Recenzij__7B1C616C559DBD16", x => x.RecenzijaReakcijaId);
                    table.ForeignKey(
                        name: "FK__Recenzija__Koris__17F790F9",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Recenzija__Recen__17036CC0",
                        column: x => x.RecenzijaId,
                        principalTable: "Recenzija",
                        principalColumn: "RecenzijaId");
                });

            migrationBuilder.CreateTable(
                name: "Rezervacija",
                columns: table => new
                {
                    RezervacijaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    FrizerId = table.Column<int>(type: "int", nullable: false),
                    Sifra = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    DatumRezervacije = table.Column<DateTime>(type: "date", nullable: false, defaultValueSql: "(getdate())"),
                    VrijemePocetka = table.Column<TimeSpan>(type: "time", nullable: false),
                    VrijemeKraja = table.Column<TimeSpan>(type: "time", nullable: false),
                    UkupnaCijena = table.Column<decimal>(type: "decimal(10,2)", nullable: false),
                    UkupnoTrajanje = table.Column<int>(type: "int", nullable: false),
                    UkupanBrojUsluga = table.Column<int>(type: "int", nullable: true),
                    StateMachine = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    NacinPlacanjaId = table.Column<int>(type: "int", nullable: false),
                    AktiviranaPromocijaId = table.Column<int>(type: "int", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Rezervac__CABA44DD5D0F9C23", x => x.RezervacijaId);
                    table.ForeignKey(
                        name: "FK__Rezervaci__Aktiv__787EE5A0",
                        column: x => x.AktiviranaPromocijaId,
                        principalTable: "AktiviranaPromocija",
                        principalColumn: "AktiviranaPromocijaId");
                    table.ForeignKey(
                        name: "FK__Rezervaci__Frize__73BA3083",
                        column: x => x.FrizerId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Rezervaci__Koris__72C60C4A",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Rezervaci__Nacin__778AC167",
                        column: x => x.NacinPlacanjaId,
                        principalTable: "NacinPlacanja",
                        principalColumn: "NacinPlacanjaId");
                });

            migrationBuilder.CreateTable(
                name: "RecenzijaOdgovorReakcija",
                columns: table => new
                {
                    RecenzijaOdgovorReakcijaId = table.Column<int>(type: "int", nullable: false),
                    RecenzijaOdgovorId = table.Column<int>(type: "int", nullable: false),
                    KorisnikId = table.Column<int>(type: "int", nullable: false),
                    JeLajk = table.Column<bool>(type: "bit", nullable: false),
                    DatumReakcije = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Recenzij__BA973BC7765F9E67", x => x.RecenzijaOdgovorReakcijaId);
                    table.ForeignKey(
                        name: "FK__Recenzija__Koris__1CBC4616",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Recenzija__Recen__1BC821DD",
                        column: x => x.RecenzijaOdgovorId,
                        principalTable: "RecenzijaOdgovor",
                        principalColumn: "RecenzijaOdgovorId");
                });

            migrationBuilder.CreateTable(
                name: "StavkeRezervacije",
                columns: table => new
                {
                    StavkeRezervacijeId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UslugaId = table.Column<int>(type: "int", nullable: false),
                    RezervacijaId = table.Column<int>(type: "int", nullable: false),
                    Cijena = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__StavkeRe__17239E701F07736A", x => x.StavkeRezervacijeId);
                    table.ForeignKey(
                        name: "FK__StavkeRez__Rezer__7D439ABD",
                        column: x => x.RezervacijaId,
                        principalTable: "Rezervacija",
                        principalColumn: "RezervacijaId");
                    table.ForeignKey(
                        name: "FK__StavkeRez__Uslug__7C4F7684",
                        column: x => x.UslugaId,
                        principalTable: "Usluga",
                        principalColumn: "UslugaId");
                });

            migrationBuilder.CreateIndex(
                name: "IX_AktiviranaPromocija_KorisnikId",
                table: "AktiviranaPromocija",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_AktiviranaPromocija_PromocijaID",
                table: "AktiviranaPromocija",
                column: "PromocijaID");

            migrationBuilder.CreateIndex(
                name: "IX_Arhiva_KorisnikId",
                table: "Arhiva",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Arhiva_UslugaId",
                table: "Arhiva",
                column: "UslugaId");

            migrationBuilder.CreateIndex(
                name: "IX_Favorit_KorisnikId",
                table: "Favorit",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Favorit_UslugaId",
                table: "Favorit",
                column: "UslugaId");

            migrationBuilder.CreateIndex(
                name: "IX_KorisniciUloge_KorisnikId",
                table: "KorisniciUloge",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_KorisniciUloge_UlogaId",
                table: "KorisniciUloge",
                column: "UlogaId");

            migrationBuilder.CreateIndex(
                name: "UQ__Korisnik__992E6F92066ADDE1",
                table: "Korisnik",
                column: "KorisnickoIme",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ__Korisnik__A9D105345A0525D1",
                table: "Korisnik",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Obavijest_KorisnikId",
                table: "Obavijest",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Ocjena_KorisnikId",
                table: "Ocjena",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Ocjena_UslugaId",
                table: "Ocjena",
                column: "UslugaId");

            migrationBuilder.CreateIndex(
                name: "IX_Promocija_UslugaId",
                table: "Promocija",
                column: "UslugaId");

            migrationBuilder.CreateIndex(
                name: "IX_Recenzija_KorisnikId",
                table: "Recenzija",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Recenzija_UslugaId",
                table: "Recenzija",
                column: "UslugaId");

            migrationBuilder.CreateIndex(
                name: "IX_RecenzijaOdgovor_KorisnikId",
                table: "RecenzijaOdgovor",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_RecenzijaOdgovor_RecenzijaId",
                table: "RecenzijaOdgovor",
                column: "RecenzijaId");

            migrationBuilder.CreateIndex(
                name: "IX_RecenzijaOdgovorReakcija_KorisnikId",
                table: "RecenzijaOdgovorReakcija",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_RecenzijaOdgovorReakcija_RecenzijaOdgovorId",
                table: "RecenzijaOdgovorReakcija",
                column: "RecenzijaOdgovorId");

            migrationBuilder.CreateIndex(
                name: "IX_RecenzijaReakcija_KorisnikId",
                table: "RecenzijaReakcija",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_RecenzijaReakcija_RecenzijaId",
                table: "RecenzijaReakcija",
                column: "RecenzijaId");

            migrationBuilder.CreateIndex(
                name: "IX_Rezervacija_AktiviranaPromocijaId",
                table: "Rezervacija",
                column: "AktiviranaPromocijaId");

            migrationBuilder.CreateIndex(
                name: "IX_Rezervacija_FrizerId",
                table: "Rezervacija",
                column: "FrizerId");

            migrationBuilder.CreateIndex(
                name: "IX_Rezervacija_KorisnikId",
                table: "Rezervacija",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Rezervacija_NacinPlacanjaId",
                table: "Rezervacija",
                column: "NacinPlacanjaId");

            migrationBuilder.CreateIndex(
                name: "IX_StavkeRezervacije_RezervacijaId",
                table: "StavkeRezervacije",
                column: "RezervacijaId");

            migrationBuilder.CreateIndex(
                name: "IX_StavkeRezervacije_UslugaId",
                table: "StavkeRezervacije",
                column: "UslugaId");

            migrationBuilder.CreateIndex(
                name: "IX_Usluga_VrstaId",
                table: "Usluga",
                column: "VrstaId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Arhiva");

            migrationBuilder.DropTable(
                name: "Favorit");

            migrationBuilder.DropTable(
                name: "KorisniciUloge");

            migrationBuilder.DropTable(
                name: "Obavijest");

            migrationBuilder.DropTable(
                name: "Ocjena");

            migrationBuilder.DropTable(
                name: "RecenzijaOdgovorReakcija");

            migrationBuilder.DropTable(
                name: "RecenzijaReakcija");

            migrationBuilder.DropTable(
                name: "StavkeRezervacije");

            migrationBuilder.DropTable(
                name: "Uloga");

            migrationBuilder.DropTable(
                name: "RecenzijaOdgovor");

            migrationBuilder.DropTable(
                name: "Rezervacija");

            migrationBuilder.DropTable(
                name: "Recenzija");

            migrationBuilder.DropTable(
                name: "AktiviranaPromocija");

            migrationBuilder.DropTable(
                name: "NacinPlacanja");

            migrationBuilder.DropTable(
                name: "Korisnik");

            migrationBuilder.DropTable(
                name: "Promocija");

            migrationBuilder.DropTable(
                name: "Usluga");

            migrationBuilder.DropTable(
                name: "VrstaUsluge");
        }
    }
}
