using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace eSalon.Services.Migrations
{
    /// <inheritdoc />
    public partial class DataSeed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Korisnik",
                columns: new[] { "KorisnikId", "DatumRegistracije", "Email", "Ime", "IsDeleted", "JeAktivan", "KorisnickoIme", "LozinkaHash", "LozinkaSalt", "Prezime", "Slika", "Telefon", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 1, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), "admin@gmail.com", "Admin", false, true, "admin", "3LwfrQwoet7CItpIVOuM0nevxfhNQ5o6fa/sIsZJp4E=", "dRwqm+pOWW2BhcWRA5l/pA==", "Admin", null, "+062303101", null },
                    { 2, new DateTime(2025, 1, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), "frizer@gmail.com", "Frizer", false, true, "frizer", "3LwfrQwoet7CItpIVOuM0nevxfhNQ5o6fa/sIsZJp4E=", "dRwqm+pOWW2BhcWRA5l/pA==", "Frizer", null, "+062303101", null },
                    { 3, new DateTime(2025, 1, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), "frizer2@gmail.com", "FrizerDva", false, true, "frizer2", "3LwfrQwoet7CItpIVOuM0nevxfhNQ5o6fa/sIsZJp4E=", "dRwqm+pOWW2BhcWRA5l/pA==", "FrizerDva", null, "+062303101", null },
                    { 4, new DateTime(2025, 1, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), "frizer3@gmail.com", "FrizerTri", false, true, "frizer3", "3LwfrQwoet7CItpIVOuM0nevxfhNQ5o6fa/sIsZJp4E=", "dRwqm+pOWW2BhcWRA5l/pA==", "FrizerTri", null, "+062303101", null },
                    { 5, new DateTime(2025, 1, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), "klijent@gmail.com", "Klijent", false, true, "klijent", "3LwfrQwoet7CItpIVOuM0nevxfhNQ5o6fa/sIsZJp4E=", "dRwqm+pOWW2BhcWRA5l/pA==", "Klijent", null, "+062303101", null },
                    { 6, new DateTime(2025, 1, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), "klijent2@gmail.com", "KlijentDva", false, true, "klijent2", "3LwfrQwoet7CItpIVOuM0nevxfhNQ5o6fa/sIsZJp4E=", "dRwqm+pOWW2BhcWRA5l/pA==", "KlijentDva", null, "+062303101", null }
                });

            migrationBuilder.InsertData(
                table: "NacinPlacanja",
                columns: new[] { "NacinPlacanjaId", "IsDeleted", "Naziv", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, false, "Gotovina", null },
                    { 2, false, "PayPal", null }
                });

            migrationBuilder.InsertData(
                table: "Uloga",
                columns: new[] { "UlogaId", "IsDeleted", "Naziv", "Opis", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, false, "Admin", "Administrator sistema", null },
                    { 2, false, "Frizer", "Frizer u salonu", null },
                    { 3, false, "Klijent", "Klijent u salonu", null }
                });

            migrationBuilder.InsertData(
                table: "VrstaUsluge",
                columns: new[] { "VrstaId", "IsDeleted", "Naziv", "Slika", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, false, "Šišanje kose", null, null },
                    { 2, false, "Farbanje kose", null, null },
                    { 3, false, "Tretmani kose", null, null },
                    { 4, false, "Frizure / Styling", null, null },
                    { 5, false, "Muško šišanje i briga o bradi", null, null },
                    { 6, false, "Pranje i priprema kose", null, null }
                });

            migrationBuilder.InsertData(
                table: "KorisniciUloge",
                columns: new[] { "KorisnikUlogaId", "DatumDodavanja", "IsDeleted", "KorisnikId", "UlogaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 1, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 1, 1, null },
                    { 2, new DateTime(2025, 1, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 2, 2, null },
                    { 3, new DateTime(2025, 1, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 3, 2, null },
                    { 4, new DateTime(2025, 1, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 4, 2, null },
                    { 5, new DateTime(2025, 1, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 3, null },
                    { 6, new DateTime(2025, 1, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 3, null }
                });

            migrationBuilder.InsertData(
                table: "Obavijest",
                columns: new[] { "ObavijestId", "DatumObavijesti", "IsDeleted", "JePogledana", "KorisnikId", "Naslov", "Sadrzaj", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 1, 20, 10, 0, 0, 0, DateTimeKind.Unspecified), false, true, 5, "Nova usluga u eSalonu", "Pozdrav Klijent,\n\nNova usluga 'Ekstenzije i nadogradnja kose' je sada dostupna u našem salonu. Dođite i isprobajte je!\n\nVaš eSalon tim", null },
                    { 2, new DateTime(2025, 1, 19, 10, 5, 0, 0, DateTimeKind.Unspecified), false, false, 5, "Nova usluga u eSalonu", "Pozdrav Klijent,\n\nNova usluga 'Keratin tretman' je sada dostupna u našem salonu. Dođite i isprobajte je!\n\nVaš eSalon tim", null },
                    { 3, new DateTime(2025, 1, 20, 10, 10, 0, 0, DateTimeKind.Unspecified), false, false, 6, "Nova usluga u eSalonu", "Pozdrav KlijentDva,\n\nNova usluga 'Ekstenzije i nadogradnja kose' je sada dostupna u našem salonu. Dođite i isprobajte je!\n\nVaš eSalon tim", null },
                    { 4, new DateTime(2025, 1, 19, 10, 15, 0, 0, DateTimeKind.Unspecified), false, true, 6, "Nova usluga u eSalonu", "Pozdrav KlijentDva,\n\nNova usluga 'Keratin tretman' je sada dostupna u našem salonu. Dođite i isprobajte je!\n\nVaš eSalon tim", null },
                    { 5, new DateTime(2026, 1, 12, 11, 0, 0, 0, DateTimeKind.Unspecified), false, false, 5, "Vaša rezervacija je odobrena", "Poštovanje Klijent,\n\nVaša rezervacija u salonu je odobrena od strane frizera FrizerDva. Molimo Vas da planirate dolazak prema odabranom terminu.\n\nDetalji rezervacije:\n- Šifra rezervacije: #Z5R2MN\n- Klijent: Klijent Klijent\n- Frizer: FrizerDva\n- Datum rezervacije: 14.02.2026\n- Vrijeme rezervacije: 14:30 - 15:20\n- Broj usluga: 2\n- Ukupan iznos: 30 KM\n\nHvala na rezervaciji!\nVaš eSalon tim", null },
                    { 6, new DateTime(2026, 1, 11, 11, 5, 0, 0, DateTimeKind.Unspecified), false, false, 6, "Vaša rezervacija je odobrena", "Poštovanje KlijentDva,\n\nVaša rezervacija u salonu je odobrena od strane frizera FrizerDva. Molimo Vas da planirate dolazak prema odabranom terminu.\n\nDetalji rezervacije:\n- Šifra rezervacije: #Q8L3ZM\n- Klijent: KlijentDva KlijentDva\n- Frizer: FrizerDva\n- Datum rezervacije: 24.02.2026\n- Vrijeme rezervacije: 13:00 - 14:55\n- Broj usluga: 3\n- Ukupan iznos: 85 KM\n\nHvala na rezervaciji!\nVaš eSalon tim", null },
                    { 7, new DateTime(2026, 1, 13, 12, 0, 0, 0, DateTimeKind.Unspecified), false, true, 3, "Nova rezervacija", "Poštovanje FrizerDva,\n\nKreirana je nova rezervacija #Z5R2MN za datum 14.02.2026.\nMolimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\nHvala,\nVaš eSalon tim", null },
                    { 8, new DateTime(2026, 1, 12, 12, 5, 0, 0, DateTimeKind.Unspecified), false, false, 3, "Nova rezervacija", "Poštovanje FrizerDva,\n\nKreirana je nova rezervacija #Q8L3ZM za datum 24.02.2026.\nMolimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\nHvala,\nVaš eSalon tim", null },
                    { 9, new DateTime(2026, 1, 11, 12, 10, 0, 0, DateTimeKind.Unspecified), false, false, 3, "Nova rezervacija", "Poštovanje FrizerDva,\n\nKreirana je nova rezervacija #P4X8LM za datum 29.01.2026.\nMolimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\nHvala,\nVaš eSalon tim", null },
                    { 10, new DateTime(2026, 1, 12, 12, 20, 0, 0, DateTimeKind.Unspecified), false, false, 2, "Nova rezervacija", "Poštovanje Frizer,\n\nKreirana je nova rezervacija #A7F9KQ za datum 28.01.2026.\nMolimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\nHvala,\nVaš eSalon tim", null },
                    { 11, new DateTime(2026, 1, 11, 12, 25, 0, 0, DateTimeKind.Unspecified), false, true, 2, "Nova rezervacija", "Poštovanje Frizer,\n\nKreirana je nova rezervacija #KQ7E2W za datum 02.03.2026.\nMolimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\nHvala,\nVaš eSalon tim", null },
                    { 12, new DateTime(2026, 1, 11, 12, 40, 0, 0, DateTimeKind.Unspecified), false, true, 4, "Nova rezervacija", "Poštovanje FrizerTri,\n\nKreirana je nova rezervacija #L9M2RZ za datum 27.01.2026.\nMolimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\nHvala,\nVaš eSalon tim", null },
                    { 13, new DateTime(2026, 1, 11, 12, 45, 0, 0, DateTimeKind.Unspecified), false, false, 4, "Nova rezervacija", "Poštovanje FrizerTri,\n\nKreirana je nova rezervacija #A9R2WX za datum 30.01.2026.\nMolimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\nHvala,\nVaš eSalon tim", null },
                    { 14, new DateTime(2026, 1, 11, 13, 0, 0, 0, DateTimeKind.Unspecified), false, false, 6, "Rezervacija je otkazana", "Poštovanje KlijentDva,\n\nNažalost, Vaša rezervacija sa šifrom #M7Q8YX, zakazana za 10.03.2026, je otkazana od strane frizera. Iskreno nam je žao zbog ove promjene i nadamo se da ćemo Vas uskoro moći ugostiti u našem salonu i pružiti Vam vrhunsku uslugu.\n\nHvala na razumijevanju,\nVaš eSalon tim", null },
                    { 15, new DateTime(2026, 1, 11, 13, 5, 0, 0, DateTimeKind.Unspecified), false, false, 5, "Rezervacija je otkazana", "Poštovanje Klijent,\n\nNažalost, Vaša rezervacija sa šifrom #K5P9LA, zakazana za 27.01.2026, je otkazana od strane frizera. Iskreno nam je žao zbog ove promjene i nadamo se da ćemo Vas uskoro moći ugostiti u našem salonu i pružiti Vam vrhunsku uslugu.\n\nHvala na razumijevanju,\nVaš eSalon tim", null }
                });

            migrationBuilder.InsertData(
                table: "Rezervacija",
                columns: new[] { "RezervacijaId", "AktiviranaPromocijaId", "DatumRezervacije", "FrizerId", "IsDeleted", "KorisnikId", "NacinPlacanjaId", "Sifra", "StateMachine", "TerminZatvoren", "UkupanBrojUsluga", "UkupnaCijena", "UkupnoTrajanje", "VrijemeBrisanja", "VrijemeKraja", "VrijemePocetka" },
                values: new object[,]
                {
                    { 5, null, new DateTime(2026, 2, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, false, 6, 1, "ZX91TU", "odobrena", true, 2, 35m, 60, null, new TimeSpan(0, 9, 0, 0, 0), new TimeSpan(0, 8, 0, 0, 0) },
                    { 6, null, new DateTime(2026, 1, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, false, 5, 1, "AS72LP", "zavrsena", true, 2, 35m, 60, null, new TimeSpan(0, 10, 0, 0, 0), new TimeSpan(0, 9, 0, 0, 0) },
                    { 7, null, new DateTime(2026, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, false, 5, 1, "ZX91TR", "zavrsena", true, 2, 270m, 150, null, new TimeSpan(0, 10, 30, 0, 0), new TimeSpan(0, 8, 0, 0, 0) },
                    { 8, null, new DateTime(2026, 1, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, false, 5, 1, "LM45OP", "zavrsena", true, 2, 35m, 45, null, new TimeSpan(0, 8, 45, 0, 0), new TimeSpan(0, 8, 0, 0, 0) },
                    { 9, null, new DateTime(2026, 1, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, false, 6, 2, "GH78XY", "zavrsena", true, 2, 275m, 100, null, new TimeSpan(0, 13, 40, 0, 0), new TimeSpan(0, 12, 0, 0, 0) },
                    { 10, null, new DateTime(2026, 2, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, false, 5, 1, "HZ12LM", "kreirana", true, 2, 50m, 60, null, new TimeSpan(0, 9, 0, 0, 0), new TimeSpan(0, 8, 0, 0, 0) },
                    { 11, null, new DateTime(2026, 1, 28, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, false, 5, 2, "A7F9KQ", "odobrena", true, 2, 30m, 55, null, new TimeSpan(0, 11, 25, 0, 0), new TimeSpan(0, 10, 30, 0, 0) },
                    { 12, null, new DateTime(2026, 1, 29, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, false, 6, 2, "P4X8LM", "kreirana", true, 1, 70m, 90, null, new TimeSpan(0, 14, 30, 0, 0), new TimeSpan(0, 13, 0, 0, 0) },
                    { 13, null, new DateTime(2026, 1, 27, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, false, 5, 1, "L9M2RZ", "odobrena", true, 1, 250m, 50, null, new TimeSpan(0, 9, 20, 0, 0), new TimeSpan(0, 8, 30, 0, 0) },
                    { 14, null, new DateTime(2026, 3, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, false, 6, 2, "KQ7E2W", "kreirana", true, 3, 70m, 90, null, new TimeSpan(0, 11, 0, 0, 0), new TimeSpan(0, 9, 30, 0, 0) },
                    { 15, null, new DateTime(2026, 2, 14, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, false, 5, 1, "Z5R2MN", "odobrena", true, 2, 30m, 50, null, new TimeSpan(0, 15, 20, 0, 0), new TimeSpan(0, 14, 30, 0, 0) },
                    { 16, null, new DateTime(2026, 3, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, false, 6, 1, "M7Q8YX", "ponistena", false, 2, 45m, 70, null, new TimeSpan(0, 11, 10, 0, 0), new TimeSpan(0, 10, 0, 0, 0) },
                    { 17, null, new DateTime(2026, 1, 27, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, false, 5, 1, "K5P9LA", "ponistena", false, 1, 30m, 30, null, new TimeSpan(0, 14, 0, 0, 0), new TimeSpan(0, 13, 30, 0, 0) },
                    { 18, null, new DateTime(2026, 2, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, false, 6, 2, "Q8L3ZM", "odobrena", true, 3, 85m, 115, null, new TimeSpan(0, 14, 55, 0, 0), new TimeSpan(0, 13, 0, 0, 0) },
                    { 19, null, new DateTime(2026, 2, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, false, 5, 2, "K8P9ZQ", "kreirana", true, 1, 200m, 60, null, new TimeSpan(0, 9, 0, 0, 0), new TimeSpan(0, 8, 0, 0, 0) },
                    { 20, null, new DateTime(2026, 1, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, false, 6, 1, "A9R2WX", "kreirana", true, 3, 65m, 100, null, new TimeSpan(0, 11, 40, 0, 0), new TimeSpan(0, 10, 0, 0, 0) }
                });

            migrationBuilder.InsertData(
                table: "Usluga",
                columns: new[] { "UslugaId", "Cijena", "DatumObjavljivanja", "IsDeleted", "Naziv", "Opis", "Slika", "Trajanje", "VrijemeBrisanja", "VrstaId" },
                values: new object[,]
                {
                    { 1, 20m, new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Šišanje kratke kose", "Šišanje kratke kose uz precizno oblikovanje koje naglašava prirodne crte lica i daje uredan i moderan izgled.", null, 30, null, 1 },
                    { 2, 25m, new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Šišanje duge kose", "Šišanje duge kose uz precizno oblikovanje koje olakšava stiliziranje i održavanje zdrave kose.", null, 50, null, 1 },
                    { 3, 15m, new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Dječije šišanje", "Precizno i sigurno šišanje kose kod djece uz fokus na udobnost i kvalitetan rezultat.", null, 30, null, 1 },
                    { 4, 40m, new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Klasično farbanje kose", "Farbanje cijele kose u željenu nijansu uz preciznu primjenu boje. Ovo farbanje osigurava dugotrajan rezultat i ravnomjernu boju. Idealno za promjenu stila ili osvježavanje postojećeg tona kose.", null, 60, null, 2 },
                    { 5, 70m, new DateTime(2025, 1, 10, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Balayage", "Tehnika prirodnog prelijevanja nijansi koja daje efekt dubine i svjetlosti u kosi. Prikladno za sve tipove kose i različite dužine, a rezultat je prirodan i sofisticiran.", null, 90, null, 2 },
                    { 6, 70m, new DateTime(2025, 1, 6, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Pramenovi", "Dodavanje svijetlijih ili tamnijih pramenova po želji klijenta za efekt dubine i teksture u kosi. Pramenovi mogu biti tanki ili široki, ovisno o željenom stilu. Ovaj tretman naglašava volumen kose i stvara moderan izgled prilagođen klijentu.", null, 75, null, 2 },
                    { 7, 250m, new DateTime(2025, 1, 8, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Regenerativni tretman oštećene kose", "Dubinska obnova oštećene kose. Obnavlja strukturu vlasi, vraća mekoću i sjaj. Pogodno za kosu oštećenu farbanjem ili stiliziranjem. Sprječava pucanje vrhova i poboljšava elastičnost kose.", null, 60, null, 3 },
                    { 8, 250m, new DateTime(2025, 1, 9, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Tretman protiv opadanja kose", "Tretman za jačanje korijena i smanjenje opadanja kose. Aktivni sastojci stimuliraju vlasište i potiču rast novih vlasi. Ojačava kosu i povećava njenu otpornost na lomljenje i oštećenja. Preporučuje se kod smanjenja gustoće kose i gubitka volumena.", null, 50, null, 3 },
                    { 9, 300m, new DateTime(2025, 1, 19, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Keratin tretman", "Keratin tretman koji poravnava kosu i smanjuje kovrčanje. Pruža dugotrajan sjaj, glatkoću i olakšava stiliziranje. Obnavlja oštećene vlasi i čini kosu mekšom i lakšom za oblikovanje. Pogodan za sve tipove kose.", null, 60, null, 3 },
                    { 10, 200m, new DateTime(2025, 1, 18, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Hidratantni tretman kose", "Intenzivna hidratacija za suhu i oštećenu kosu. Dubinski njeguje vlasi, vraća vlagu i elastičnost kose. Pomaže u smanjenju lomljenja i oštećenja uz povećanje sjaja. Preporučuje se kod suhe, ispucale ili hemijski tretirane kose.", null, 60, null, 3 },
                    { 11, 30m, new DateTime(2025, 1, 6, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Uvijanje kose", "Uvijanje kose za definisane lokne ili blage valove. Može se prilagoditi različitim dužinama i teksturama kose. Idealno za svaki stil i priliku.", null, 30, null, 4 },
                    { 12, 30m, new DateTime(2025, 1, 4, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Peglanje kose", "Ravnanje kose peglom za glatku i sjajnu kosu. Pruža uredan izgled i olakšava stiliziranje. Pogodno za sve tipove kose.", null, 30, null, 4 },
                    { 13, 20m, new DateTime(2025, 1, 4, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Frizura – rep", "Stilizovanje kose u rep. Može biti visoki, niski ili srednji rep. Prikladno za svakodnevne ili svečane prilike. Pruža uredan i elegantan izgled koji se dugo održava.", null, 20, null, 4 },
                    { 14, 25m, new DateTime(2025, 1, 7, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Frizura – punđa", "Stilizovanje kose u punđu. Može biti niska, visoka ili klasična punđa. Pogodno za formalne događaje ili elegantan dnevni izgled. Zadržava oblik dugo i pruža uredan završni dojam.", null, 30, null, 4 },
                    { 15, 250m, new DateTime(2025, 1, 20, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Ekstenzije i nadogradnja kose", "Profesionalno dodavanje dužine i volumena kose. Omogućava prirodan izgled i dodatni volumen, prilagođeno tipu i strukturi kose. Pogodno za posebne prilike ili svakodnevni stil.", null, 120, null, 4 },
                    { 16, 15m, new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Klasično muško šišanje", "Standardno šišanje za muškarce. Precizno oblikovanje i skraćivanje kose prema želji klijenta. Pruža uredan, profesionalan i moderan izgled. Pogodno za sve tipove kose.", null, 30, null, 5 },
                    { 17, 20m, new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Moderno muško šišanje (FADE)", "Trendy muško šišanje s fade efektom. Obuhvata fade, undercut ili kombinaciju modernih stilova. Omogućava lako stiliziranje i moderan izgled.", null, 40, null, 5 },
                    { 18, 15m, new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Uređivanje brade", "Brijanje, trimanje i oblikovanje brade prema željenom stilu. Pruža uredan i sofisticiran izgled. Pogodno za sve tipove brade.", null, 20, null, 5 },
                    { 19, 15m, new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Standardno pranje kose", "Klasično pranje kose uz nježnu masažu vlasišta. Uključuje nanošenje regeneratora ili maske za dodatnu njegu i hidrataciju. Prikladno za sve tipove kose i pripremu za šišanje ili stiliziranje.", null, 25, null, 6 },
                    { 20, 20m, new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Temeljito pranje kose", "Temeljito pranje kose uz masažu koje uklanja višak masnoće i nečistoće. Pruža osjećaj čiste i osvježene kose te priprema kosu za tretmane ili stiliziranje. Prikladno za sve tipove kose.", null, 30, null, 6 }
                });

            migrationBuilder.InsertData(
                table: "Arhiva",
                columns: new[] { "ArhivaId", "DatumDodavanja", "IsDeleted", "KorisnikId", "UslugaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 1, 2, 12, 0, 0, 123, DateTimeKind.Unspecified), false, 5, 1, null },
                    { 2, new DateTime(2026, 1, 2, 13, 30, 0, 456, DateTimeKind.Unspecified), false, 5, 4, null },
                    { 3, new DateTime(2026, 1, 6, 11, 15, 0, 789, DateTimeKind.Unspecified), false, 5, 6, null },
                    { 4, new DateTime(2026, 1, 8, 14, 45, 0, 321, DateTimeKind.Unspecified), false, 5, 7, null },
                    { 5, new DateTime(2026, 1, 6, 16, 20, 0, 654, DateTimeKind.Unspecified), false, 5, 11, null },
                    { 6, new DateTime(2026, 1, 7, 10, 10, 0, 987, DateTimeKind.Unspecified), false, 5, 14, null },
                    { 7, new DateTime(2026, 1, 2, 15, 0, 0, 111, DateTimeKind.Unspecified), false, 5, 16, null },
                    { 8, new DateTime(2026, 1, 2, 12, 5, 0, 222, DateTimeKind.Unspecified), false, 6, 2, null },
                    { 9, new DateTime(2026, 1, 10, 11, 10, 0, 333, DateTimeKind.Unspecified), false, 6, 5, null },
                    { 10, new DateTime(2026, 1, 9, 14, 25, 0, 444, DateTimeKind.Unspecified), false, 6, 8, null },
                    { 11, new DateTime(2026, 1, 19, 10, 30, 0, 555, DateTimeKind.Unspecified), false, 6, 9, null },
                    { 12, new DateTime(2026, 1, 4, 12, 45, 0, 666, DateTimeKind.Unspecified), false, 6, 12, null },
                    { 13, new DateTime(2026, 1, 4, 13, 0, 0, 777, DateTimeKind.Unspecified), false, 6, 13, null },
                    { 14, new DateTime(2026, 1, 20, 12, 15, 0, 888, DateTimeKind.Unspecified), false, 6, 15, null },
                    { 15, new DateTime(2026, 1, 2, 16, 0, 0, 999, DateTimeKind.Unspecified), false, 6, 20, null }
                });

            migrationBuilder.InsertData(
                table: "Favorit",
                columns: new[] { "FavoritId", "DatumDodavanja", "IsDeleted", "KorisnikId", "UslugaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 1, 3, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 1, null },
                    { 2, new DateTime(2026, 1, 11, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 5, null },
                    { 3, new DateTime(2026, 1, 7, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 6, null },
                    { 4, new DateTime(2026, 1, 10, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 8, null },
                    { 5, new DateTime(2026, 1, 20, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 10, null },
                    { 6, new DateTime(2026, 1, 5, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 12, null },
                    { 7, new DateTime(2026, 1, 21, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 15, null },
                    { 8, new DateTime(2026, 1, 3, 11, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 2, null },
                    { 9, new DateTime(2026, 1, 3, 12, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 3, null },
                    { 10, new DateTime(2026, 1, 3, 13, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 4, null },
                    { 11, new DateTime(2026, 1, 9, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 7, null },
                    { 12, new DateTime(2026, 1, 20, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 9, null },
                    { 13, new DateTime(2026, 1, 7, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 11, null },
                    { 14, new DateTime(2026, 1, 8, 10, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 14, null },
                    { 15, new DateTime(2026, 1, 3, 14, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 16, null }
                });

            migrationBuilder.InsertData(
                table: "Ocjena",
                columns: new[] { "OcjenaId", "DatumOcjenjivanja", "IsDeleted", "KorisnikId", "UslugaId", "Vrijednost", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 12, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 1, 5, null },
                    { 2, new DateTime(2025, 12, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 12, 4, null },
                    { 3, new DateTime(2025, 12, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 5, 5, null },
                    { 4, new DateTime(2025, 12, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 8, 4, null },
                    { 5, new DateTime(2025, 12, 17, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 3, 4, null },
                    { 6, new DateTime(2025, 12, 17, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 19, 5, null },
                    { 7, new DateTime(2025, 12, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 4, 3, null },
                    { 8, new DateTime(2025, 12, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 20, 4, null },
                    { 9, new DateTime(2026, 2, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 17, 5, null },
                    { 10, new DateTime(2026, 2, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 18, 4, null },
                    { 11, new DateTime(2026, 1, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 20, 5, null },
                    { 12, new DateTime(2026, 1, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 15, 4, null },
                    { 13, new DateTime(2026, 1, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 6, 8, 4, null },
                    { 14, new DateTime(2026, 2, 13, 0, 0, 0, 0, DateTimeKind.Unspecified), false, 5, 19, 5, null }
                });

            migrationBuilder.InsertData(
                table: "Promocija",
                columns: new[] { "PromocijaID", "DatumKraja", "DatumPocetka", "IsDeleted", "Kod", "Naziv", "Opis", "Popust", "Status", "UslugaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 12, 20, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 12, 5, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "AB12CD", "Novogodišnji popust", "Iskoristite popust za šišanje kratke kose i zablistajte u prazničnom periodu. Naši stručni frizeri pažljivo će oblikovati vašu kosu, naglasiti prirodne crte lica i osigurati uredan, moderan izgled koji će trajati. Savršena prilika da osvježite svoj stil i osjećate se samouvjereno u svakom trenutku.", 20m, true, 1, null },
                    { 2, new DateTime(2025, 12, 28, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 12, 10, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "EF34GH", "Ekskluzivni tretman", "Balayage tretman po sniženoj cijeni za savršen izgled kose pred kraj godine. Naši frizeri pažljivo će nanijeti nijanse koje naglašavaju prirodnu ljepotu vaše kose, dodajući volumen i sjaj za elegantan i sofisticiran završni dojam.", 30m, true, 5, null },
                    { 3, new DateTime(2025, 12, 22, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 12, 7, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "IJ56KL", "Dječije veselje", "Sigurno i precizno dječije šišanje po sniženoj cijeni, za zadovoljstvo mališana.", 15m, true, 3, null },
                    { 4, new DateTime(2025, 12, 30, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 12, 8, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "MN78OP", "Savršena boja", "Klasično farbanje kose po promotivnoj cijeni, za osvježavanje i ujednačen ton kose, dajući joj zdrav i sjajan izgled.", 40m, true, 4, null },
                    { 5, new DateTime(2025, 12, 29, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 12, 12, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "QR90ST", "Muški stil", "Standardno muško šišanje po sniženoj cijeni za elegantan i uredan izgled.", 25m, true, 16, null },
                    { 6, new DateTime(2026, 2, 28, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 1, 2, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "UV12WX", "Frizerski popust", "Iskoristite popust na šišanje duge kose i osvježite svoj stil, uz precizno oblikovanje koje naglašava prirodne crte lica i daje uredan, moderan izgled.", 20m, true, 2, null },
                    { 7, new DateTime(2026, 3, 5, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 1, 5, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "YZ34AB", "Pramenovi akcija", "Pramenovi sada po sniženoj cijeni za moderan i voluminozan izgled, uz naglašavanje teksture i svjetlijih tonova koji daju prirodan sjaj i dubinu kose.", 35m, true, 6, null },
                    { 8, new DateTime(2026, 2, 25, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 1, 10, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "CD56EF", "Keratin popust", "Keratin tretman po promotivnoj cijeni za glatku, sjajnu i njegovan izgled kose, koji smanjuje kovrčanje i olakšava svakodnevno stiliziranje.", 40m, true, 9, null },
                    { 9, new DateTime(2026, 3, 1, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 1, 12, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "GH78IJ", "Hidratacija kose", "Dubinska hidratacija kose po promotivnoj cijeni, pogodna za suhu i oštećenu kosu.", 25m, true, 10, null },
                    { 10, new DateTime(2026, 2, 28, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 1, 11, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "KL90MN", "Uvijanje akcija", "Iskoristite priliku dok traje promocija – uvijanje kose po sniženoj cijeni za definisane lokne ili blage valove koje će vašem izgledu dati poseban šarm.", 30m, true, 11, null },
                    { 11, new DateTime(2026, 4, 15, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 4, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "RG07AP", "Proljetni regenerativni tretman", "Dubinska obnova kose na popustu! Vaša kosa će biti mekana, sjajna i obnovljena. Savršeno za oštećenu kosu i obnavljanje strukture vlasi.", 20m, true, 7, null },
                    { 12, new DateTime(2026, 4, 29, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 4, 16, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "FP14AP", "Elegantna punđa", "Stilizovanje punđe po promotivnoj cijeni! Idealan izbor za formalne događaje ili elegantan dnevni izgled. Iskoristite priliku i zablistajte.", 25m, true, 14, null },
                    { 13, new DateTime(2026, 3, 18, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 2, 27, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "WX56YZ", "Muški tretman", "Uređivanje brade po promotivnoj cijeni za sofisticiran izgled. Iskoristite priliku da oblikujete bradu i postignete uredan, stilizovan izgled.", 20m, true, 18, null },
                    { 14, new DateTime(2026, 3, 12, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 2, 28, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "AB78CD", "Standardno pranje", "Standardno pranje kose po sniženoj cijeni za čistu i njegovanu kosu. Iskoristite priliku da osjetite svježinu i mekoću svake vlasi.", 25m, true, 19, null },
                    { 15, new DateTime(2026, 3, 15, 23, 59, 0, 0, DateTimeKind.Unspecified), new DateTime(2026, 2, 26, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "EF90GH", "Peglanje popust", "Peglanje kose sada po promotivnoj cijeni za glatku i sjajnu kosu. Iskoristite priliku da vaša kosa izgleda besprijekorno svaki dan.", 30m, true, 12, null }
                });

            migrationBuilder.InsertData(
                table: "Recenzija",
                columns: new[] { "RecenzijaId", "BrojLajkova", "DatumDodavanja", "IsDeleted", "Komentar", "KorisnikId", "UslugaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 12, 11, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Sjajno šišanje, kosa je uredno oblikovana i vrlo sam zadovoljna rezultatom.", 5, 1, null },
                    { 2, 1, new DateTime(2025, 12, 11, 11, 0, 0, 0, DateTimeKind.Unspecified), false, "Peglanje kose je bilo besprijekorno, kosa je ostala ravna cijeli dan.", 5, 12, null },
                    { 3, 1, new DateTime(2025, 12, 16, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Balayage je ispao prirodno i prekrasno, jako sam zadovoljna.", 5, 5, null },
                    { 4, 1, new DateTime(2025, 12, 16, 12, 0, 0, 0, DateTimeKind.Unspecified), false, "Tretman protiv opadanja kose je djelovao od prvog dana, vlasište je puno zdravije.", 5, 8, null },
                    { 5, 1, new DateTime(2025, 12, 17, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Dječije šišanje je prošlo super, dijete je bilo mirno i zadovoljno.", 6, 3, null },
                    { 6, 1, new DateTime(2025, 12, 17, 11, 0, 0, 0, DateTimeKind.Unspecified), false, "Pranje kose je bilo odlično, kosa je čista i svilenkasta, a masaža opuštajuća.", 6, 19, null },
                    { 7, 1, new DateTime(2026, 1, 12, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Šišanje je perfektno, rezultat je uredan i moderan.", 5, 17, null }
                });

            migrationBuilder.InsertData(
                table: "Recenzija",
                columns: new[] { "RecenzijaId", "BrojDislajkova", "DatumDodavanja", "IsDeleted", "Komentar", "KorisnikId", "UslugaId", "VrijemeBrisanja" },
                values: new object[] { 8, 1, new DateTime(2026, 1, 12, 11, 0, 0, 0, DateTimeKind.Unspecified), false, "Uređivanje brade je vrlo precizno, baš kako sam htio.", 5, 18, null });

            migrationBuilder.InsertData(
                table: "Recenzija",
                columns: new[] { "RecenzijaId", "BrojLajkova", "DatumDodavanja", "IsDeleted", "Komentar", "KorisnikId", "UslugaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 9, 1, new DateTime(2026, 1, 13, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Temeljito pranje kose je osvježilo moju kosu, savršeno iskustvo.", 5, 20, null },
                    { 10, 1, new DateTime(2026, 1, 12, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Tretman protiv opadanja kose djeluje super, kosa je gušća nego prije.", 6, 8, null }
                });

            migrationBuilder.InsertData(
                table: "Recenzija",
                columns: new[] { "RecenzijaId", "DatumDodavanja", "IsDeleted", "Komentar", "KorisnikId", "UslugaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 11, new DateTime(2026, 1, 12, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Pranje kose je bilo vrlo prijatno, masaža vlasišta je opuštajuća, a kosa je poslije veoma mekana i sjajna.", 5, 19, null },
                    { 12, new DateTime(2026, 1, 12, 11, 0, 0, 0, DateTimeKind.Unspecified), false, "Kosa je nakon pranja mekana, čista i svilenkasta, osjećaj je vrlo osvježavajući.", 6, 20, null }
                });

            migrationBuilder.InsertData(
                table: "StavkeRezervacije",
                columns: new[] { "StavkeRezervacijeId", "Cijena", "IsDeleted", "RezervacijaId", "UslugaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 9, 20m, false, 5, 17, null },
                    { 10, 15m, false, 5, 18, null },
                    { 11, 20m, false, 6, 17, null },
                    { 12, 15m, false, 6, 18, null },
                    { 13, 20m, false, 7, 20, null },
                    { 14, 250m, false, 7, 15, null },
                    { 15, 20m, false, 8, 13, null },
                    { 16, 15m, false, 8, 19, null },
                    { 17, 25m, false, 9, 2, null },
                    { 18, 250m, false, 9, 8, null },
                    { 19, 20m, false, 10, 1, null },
                    { 20, 30m, false, 10, 12, null },
                    { 21, 15m, false, 11, 3, null },
                    { 22, 15m, false, 11, 19, null },
                    { 23, 70m, false, 12, 5, null },
                    { 24, 250m, false, 13, 8, null },
                    { 25, 20m, false, 14, 1, null },
                    { 26, 30m, false, 14, 12, null },
                    { 27, 20m, false, 14, 20, null },
                    { 28, 15m, false, 15, 16, null },
                    { 29, 15m, false, 15, 18, null },
                    { 30, 25m, false, 16, 2, null },
                    { 31, 20m, false, 16, 13, null },
                    { 32, 30m, false, 17, 12, null },
                    { 33, 15m, false, 18, 19, null },
                    { 34, 40m, false, 18, 4, null },
                    { 35, 30m, false, 18, 11, null },
                    { 36, 200m, false, 19, 10, null },
                    { 37, 20m, false, 20, 20, null },
                    { 38, 25m, false, 20, 2, null },
                    { 39, 20m, false, 20, 13, null }
                });

            migrationBuilder.InsertData(
                table: "AktiviranaPromocija",
                columns: new[] { "AktiviranaPromocijaId", "Aktivirana", "DatumAktiviranja", "IsDeleted", "Iskoristena", "KorisnikId", "PromocijaID", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, true, new DateTime(2025, 12, 6, 12, 0, 0, 0, DateTimeKind.Unspecified), false, true, 5, 1, null },
                    { 2, true, new DateTime(2025, 12, 12, 11, 0, 0, 0, DateTimeKind.Unspecified), false, true, 5, 2, null },
                    { 3, true, new DateTime(2025, 12, 10, 13, 0, 0, 0, DateTimeKind.Unspecified), false, true, 6, 3, null },
                    { 4, true, new DateTime(2025, 12, 12, 16, 0, 0, 0, DateTimeKind.Unspecified), false, true, 6, 4, null },
                    { 5, true, new DateTime(2026, 1, 3, 10, 0, 0, 0, DateTimeKind.Unspecified), false, false, 5, 6, null },
                    { 6, true, new DateTime(2026, 1, 6, 12, 0, 0, 0, DateTimeKind.Unspecified), false, false, 5, 7, null },
                    { 7, true, new DateTime(2026, 1, 11, 11, 0, 0, 0, DateTimeKind.Unspecified), false, false, 6, 8, null },
                    { 8, true, new DateTime(2026, 1, 13, 14, 0, 0, 0, DateTimeKind.Unspecified), false, false, 6, 9, null }
                });

            migrationBuilder.InsertData(
                table: "RecenzijaOdgovor",
                columns: new[] { "RecenzijaOdgovorId", "BrojLajkova", "DatumDodavanja", "IsDeleted", "Komentar", "KorisnikId", "RecenzijaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 12, 12, 9, 30, 0, 0, DateTimeKind.Unspecified), false, "Kosa izgleda stvarno uredno nakon šišanja, meni se moja jako dopada.", 6, 1, null },
                    { 2, 1, new DateTime(2025, 12, 12, 9, 40, 0, 0, DateTimeKind.Unspecified), false, "Drago mi je da si zadovoljna krajnjim rezultatom kao i ja sa svojim.", 5, 1, null },
                    { 3, 1, new DateTime(2025, 12, 18, 11, 5, 0, 0, DateTimeKind.Unspecified), false, "Drago mi je da si uživala u pranju kao i ja, masaža zaista opušta.", 5, 6, null },
                    { 4, 1, new DateTime(2025, 12, 18, 11, 10, 0, 0, DateTimeKind.Unspecified), false, "Da, osjećaj nakon pranja je stvarno osvježavajući.", 6, 6, null },
                    { 5, 1, new DateTime(2026, 1, 14, 10, 5, 0, 0, DateTimeKind.Unspecified), false, "Kosa je stvarno mekša nego prije, super osjećaj.", 6, 9, null }
                });

            migrationBuilder.InsertData(
                table: "RecenzijaOdgovor",
                columns: new[] { "RecenzijaOdgovorId", "DatumDodavanja", "IsDeleted", "Komentar", "KorisnikId", "RecenzijaId", "VrijemeBrisanja" },
                values: new object[] { 6, new DateTime(2026, 1, 14, 10, 10, 0, 0, DateTimeKind.Unspecified), false, "Drago mi je da primjećuješ razliku kao i ja, cilj je imati baš ovakav osjećaj.", 5, 9, null });

            migrationBuilder.InsertData(
                table: "RecenzijaOdgovor",
                columns: new[] { "RecenzijaOdgovorId", "BrojLajkova", "DatumDodavanja", "IsDeleted", "Komentar", "KorisnikId", "RecenzijaId", "VrijemeBrisanja" },
                values: new object[] { 7, 1, new DateTime(2025, 12, 17, 10, 5, 0, 0, DateTimeKind.Unspecified), false, "Rezultat je stvarno prirodan, sve pohvale.", 6, 3, null });

            migrationBuilder.InsertData(
                table: "RecenzijaOdgovor",
                columns: new[] { "RecenzijaOdgovorId", "DatumDodavanja", "IsDeleted", "Komentar", "KorisnikId", "RecenzijaId", "VrijemeBrisanja" },
                values: new object[] { 8, new DateTime(2025, 12, 17, 10, 10, 0, 0, DateTimeKind.Unspecified), false, "Tako je, stvarno sam zadovoljna jer je efekat baš prirodan i svjež.", 5, 3, null });

            migrationBuilder.InsertData(
                table: "RecenzijaOdgovor",
                columns: new[] { "RecenzijaOdgovorId", "BrojLajkova", "DatumDodavanja", "IsDeleted", "Komentar", "KorisnikId", "RecenzijaId", "VrijemeBrisanja" },
                values: new object[] { 9, 1, new DateTime(2026, 1, 12, 10, 5, 0, 0, DateTimeKind.Unspecified), false, "Kosa je stvarno mekša i sjajnija, odlično iskustvo.", 6, 11, null });

            migrationBuilder.InsertData(
                table: "RecenzijaOdgovor",
                columns: new[] { "RecenzijaOdgovorId", "DatumDodavanja", "IsDeleted", "Komentar", "KorisnikId", "RecenzijaId", "VrijemeBrisanja" },
                values: new object[] { 10, new DateTime(2026, 1, 12, 10, 10, 0, 0, DateTimeKind.Unspecified), false, "Drago mi je da i ti primjećuješ efekat, baš je cilj da kosa bude mekša. Sve preporuke.", 5, 11, null });

            migrationBuilder.InsertData(
                table: "RecenzijaOdgovor",
                columns: new[] { "RecenzijaOdgovorId", "BrojLajkova", "DatumDodavanja", "IsDeleted", "Komentar", "KorisnikId", "RecenzijaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 11, 1, new DateTime(2026, 1, 12, 10, 5, 0, 0, DateTimeKind.Unspecified), false, "Super što tretman daje vidljive rezultate, kosa je stvarno gušća.", 5, 10, null },
                    { 12, 1, new DateTime(2026, 1, 12, 10, 10, 0, 0, DateTimeKind.Unspecified), false, "Da, stvarno se osjeti poboljšanje, kosa je puno zdravija.", 6, 10, null },
                    { 13, 1, new DateTime(2026, 1, 12, 10, 15, 0, 0, DateTimeKind.Unspecified), false, "Drago mi je da i ti primjećuješ razliku. Sve pohvale stvarno za tretman.", 5, 10, null }
                });

            migrationBuilder.InsertData(
                table: "RecenzijaOdgovor",
                columns: new[] { "RecenzijaOdgovorId", "DatumDodavanja", "IsDeleted", "Komentar", "KorisnikId", "RecenzijaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 14, new DateTime(2026, 1, 12, 11, 5, 0, 0, DateTimeKind.Unspecified), false, "Daa, krajnji rezultat je baš super.", 6, 8, null },
                    { 15, new DateTime(2025, 12, 16, 12, 10, 0, 0, DateTimeKind.Unspecified), false, "Primijetila sam poboljšanje u teksturi kose i vlasište izgleda zdravije, stvarno djeluje.", 6, 4, null }
                });

            migrationBuilder.InsertData(
                table: "RecenzijaReakcija",
                columns: new[] { "RecenzijaReakcijaId", "DatumReakcije", "IsDeleted", "JeLajk", "KorisnikId", "RecenzijaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 12, 12, 10, 0, 0, 0, DateTimeKind.Unspecified), false, true, 6, 1, null },
                    { 2, new DateTime(2025, 12, 12, 11, 0, 0, 0, DateTimeKind.Unspecified), false, true, 6, 2, null },
                    { 3, new DateTime(2025, 12, 17, 12, 0, 0, 0, DateTimeKind.Unspecified), false, true, 6, 3, null },
                    { 4, new DateTime(2025, 12, 17, 13, 0, 0, 0, DateTimeKind.Unspecified), false, true, 6, 4, null },
                    { 5, new DateTime(2025, 12, 18, 10, 0, 0, 0, DateTimeKind.Unspecified), false, true, 5, 5, null },
                    { 6, new DateTime(2025, 12, 18, 11, 0, 0, 0, DateTimeKind.Unspecified), false, true, 5, 6, null },
                    { 7, new DateTime(2026, 1, 13, 10, 0, 0, 0, DateTimeKind.Unspecified), false, true, 6, 7, null },
                    { 8, new DateTime(2026, 1, 13, 11, 0, 0, 0, DateTimeKind.Unspecified), false, false, 6, 8, null },
                    { 9, new DateTime(2026, 1, 14, 10, 0, 0, 0, DateTimeKind.Unspecified), false, true, 6, 9, null },
                    { 10, new DateTime(2026, 1, 13, 10, 0, 0, 0, DateTimeKind.Unspecified), false, true, 5, 10, null }
                });

            migrationBuilder.InsertData(
                table: "RecenzijaOdgovorReakcija",
                columns: new[] { "RecenzijaOdgovorReakcijaId", "DatumReakcije", "IsDeleted", "JeLajk", "KorisnikId", "RecenzijaOdgovorId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 12, 12, 9, 35, 0, 0, DateTimeKind.Unspecified), false, true, 5, 1, null },
                    { 2, new DateTime(2025, 12, 18, 11, 8, 0, 0, DateTimeKind.Unspecified), false, true, 6, 3, null },
                    { 3, new DateTime(2026, 1, 14, 10, 7, 0, 0, DateTimeKind.Unspecified), false, true, 5, 5, null },
                    { 4, new DateTime(2025, 12, 17, 10, 8, 0, 0, DateTimeKind.Unspecified), false, true, 5, 7, null },
                    { 5, new DateTime(2026, 1, 12, 10, 6, 0, 0, DateTimeKind.Unspecified), false, true, 5, 9, null },
                    { 6, new DateTime(2026, 1, 12, 10, 7, 0, 0, DateTimeKind.Unspecified), false, true, 6, 11, null },
                    { 7, new DateTime(2026, 1, 12, 10, 12, 0, 0, DateTimeKind.Unspecified), false, true, 5, 12, null },
                    { 8, new DateTime(2026, 1, 12, 10, 16, 0, 0, DateTimeKind.Unspecified), false, true, 6, 13, null },
                    { 9, new DateTime(2025, 12, 12, 9, 45, 0, 0, DateTimeKind.Unspecified), false, true, 6, 2, null },
                    { 10, new DateTime(2025, 12, 18, 11, 12, 0, 0, DateTimeKind.Unspecified), false, true, 5, 4, null }
                });

            migrationBuilder.InsertData(
                table: "Rezervacija",
                columns: new[] { "RezervacijaId", "AktiviranaPromocijaId", "DatumRezervacije", "FrizerId", "IsDeleted", "KorisnikId", "NacinPlacanjaId", "Sifra", "StateMachine", "TerminZatvoren", "UkupanBrojUsluga", "UkupnaCijena", "UkupnoTrajanje", "VrijemeBrisanja", "VrijemeKraja", "VrijemePocetka" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 12, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, false, 5, 1, "QW8E2R", "zavrsena", true, 2, 46m, 60, null, new TimeSpan(0, 10, 0, 0, 0), new TimeSpan(0, 9, 0, 0, 0) },
                    { 2, 2, new DateTime(2025, 12, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, false, 5, 1, "GH12JK", "zavrsena", true, 2, 299m, 140, null, new TimeSpan(0, 10, 20, 0, 0), new TimeSpan(0, 8, 0, 0, 0) },
                    { 3, 3, new DateTime(2025, 12, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, false, 6, 2, "KL34MN", "zavrsena", true, 2, 27.75m, 55, null, new TimeSpan(0, 8, 55, 0, 0), new TimeSpan(0, 8, 0, 0, 0) },
                    { 4, 4, new DateTime(2025, 12, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, false, 6, 2, "OP56QR", "zavrsena", true, 2, 44m, 90, null, new TimeSpan(0, 9, 30, 0, 0), new TimeSpan(0, 8, 0, 0, 0) }
                });

            migrationBuilder.InsertData(
                table: "StavkeRezervacije",
                columns: new[] { "StavkeRezervacijeId", "Cijena", "IsDeleted", "RezervacijaId", "UslugaId", "VrijemeBrisanja" },
                values: new object[,]
                {
                    { 1, 16m, false, 1, 1, null },
                    { 2, 30m, false, 1, 12, null },
                    { 3, 49m, false, 2, 5, null },
                    { 4, 250m, false, 2, 8, null },
                    { 5, 12.75m, false, 3, 3, null },
                    { 6, 15m, false, 3, 19, null },
                    { 7, 24m, false, 4, 4, null },
                    { 8, 20m, false, 4, 20, null }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "AktiviranaPromocija",
                keyColumn: "AktiviranaPromocijaId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "AktiviranaPromocija",
                keyColumn: "AktiviranaPromocijaId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "AktiviranaPromocija",
                keyColumn: "AktiviranaPromocijaId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "AktiviranaPromocija",
                keyColumn: "AktiviranaPromocijaId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Arhiva",
                keyColumn: "ArhivaId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Favorit",
                keyColumn: "FavoritId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "KorisniciUloge",
                keyColumn: "KorisnikUlogaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "KorisniciUloge",
                keyColumn: "KorisnikUlogaId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "KorisniciUloge",
                keyColumn: "KorisnikUlogaId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "KorisniciUloge",
                keyColumn: "KorisnikUlogaId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "KorisniciUloge",
                keyColumn: "KorisnikUlogaId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "KorisniciUloge",
                keyColumn: "KorisnikUlogaId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Obavijest",
                keyColumn: "ObavijestId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Ocjena",
                keyColumn: "OcjenaId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Recenzija",
                keyColumn: "RecenzijaId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovorReakcija",
                keyColumn: "RecenzijaOdgovorReakcijaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovorReakcija",
                keyColumn: "RecenzijaOdgovorReakcijaId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovorReakcija",
                keyColumn: "RecenzijaOdgovorReakcijaId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovorReakcija",
                keyColumn: "RecenzijaOdgovorReakcijaId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovorReakcija",
                keyColumn: "RecenzijaOdgovorReakcijaId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovorReakcija",
                keyColumn: "RecenzijaOdgovorReakcijaId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovorReakcija",
                keyColumn: "RecenzijaOdgovorReakcijaId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovorReakcija",
                keyColumn: "RecenzijaOdgovorReakcijaId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovorReakcija",
                keyColumn: "RecenzijaOdgovorReakcijaId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovorReakcija",
                keyColumn: "RecenzijaOdgovorReakcijaId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "RecenzijaReakcija",
                keyColumn: "RecenzijaReakcijaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "RecenzijaReakcija",
                keyColumn: "RecenzijaReakcijaId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "RecenzijaReakcija",
                keyColumn: "RecenzijaReakcijaId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "RecenzijaReakcija",
                keyColumn: "RecenzijaReakcijaId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "RecenzijaReakcija",
                keyColumn: "RecenzijaReakcijaId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "RecenzijaReakcija",
                keyColumn: "RecenzijaReakcijaId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "RecenzijaReakcija",
                keyColumn: "RecenzijaReakcijaId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "RecenzijaReakcija",
                keyColumn: "RecenzijaReakcijaId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "RecenzijaReakcija",
                keyColumn: "RecenzijaReakcijaId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "RecenzijaReakcija",
                keyColumn: "RecenzijaReakcijaId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 26);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 27);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 28);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 29);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 30);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 31);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 32);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 33);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 34);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 35);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 36);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 37);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 38);

            migrationBuilder.DeleteData(
                table: "StavkeRezervacije",
                keyColumn: "StavkeRezervacijeId",
                keyValue: 39);

            migrationBuilder.DeleteData(
                table: "Korisnik",
                keyColumn: "KorisnikId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Recenzija",
                keyColumn: "RecenzijaId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Recenzija",
                keyColumn: "RecenzijaId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Recenzija",
                keyColumn: "RecenzijaId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Recenzija",
                keyColumn: "RecenzijaId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Recenzija",
                keyColumn: "RecenzijaId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "RecenzijaOdgovor",
                keyColumn: "RecenzijaOdgovorId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "Rezervacija",
                keyColumn: "RezervacijaId",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "Uloga",
                keyColumn: "UlogaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Uloga",
                keyColumn: "UlogaId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Uloga",
                keyColumn: "UlogaId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "AktiviranaPromocija",
                keyColumn: "AktiviranaPromocijaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "AktiviranaPromocija",
                keyColumn: "AktiviranaPromocijaId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "AktiviranaPromocija",
                keyColumn: "AktiviranaPromocijaId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "AktiviranaPromocija",
                keyColumn: "AktiviranaPromocijaId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Korisnik",
                keyColumn: "KorisnikId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Korisnik",
                keyColumn: "KorisnikId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Korisnik",
                keyColumn: "KorisnikId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "NacinPlacanja",
                keyColumn: "NacinPlacanjaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "NacinPlacanja",
                keyColumn: "NacinPlacanjaId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Recenzija",
                keyColumn: "RecenzijaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Recenzija",
                keyColumn: "RecenzijaId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Recenzija",
                keyColumn: "RecenzijaId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Recenzija",
                keyColumn: "RecenzijaId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Recenzija",
                keyColumn: "RecenzijaId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Recenzija",
                keyColumn: "RecenzijaId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Korisnik",
                keyColumn: "KorisnikId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Korisnik",
                keyColumn: "KorisnikId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Promocija",
                keyColumn: "PromocijaID",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "VrstaUsluge",
                keyColumn: "VrstaId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "VrstaUsluge",
                keyColumn: "VrstaId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Usluga",
                keyColumn: "UslugaId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "VrstaUsluge",
                keyColumn: "VrstaId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "VrstaUsluge",
                keyColumn: "VrstaId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "VrstaUsluge",
                keyColumn: "VrstaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "VrstaUsluge",
                keyColumn: "VrstaId",
                keyValue: 2);
        }
    }
}
