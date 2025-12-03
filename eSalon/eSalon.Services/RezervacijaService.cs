using Azure.Core;
using eSalon.Model;
using eSalon.Model.Exceptions;
using eSalon.Model.Requests;
using eSalon.Model.SearchObjects;
using eSalon.Services.BaseServicesImplementation;
using eSalon.Services.Database;
using eSalon.Services.Helpers;
using eSalon.Services.RezervacijaStateMachine;
using eSalon.Services.Validator.Implementation;
using eSalon.Services.Validator.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace eSalon.Services
{
    public class RezervacijaService : BaseCRUDServiceAsync<Model.Rezervacija, RezervacijaSearchObject, Database.Rezervacija, RezervacijaInsertRequest, RezervacijaUpdateRequest>, IRezervacijaService
    {
        private readonly IRezervacijaValidator _rezervacijaValidator;
        private readonly BaseRezervacijaState _baseRezervacijaState;
        public RezervacijaService(ESalonContext context, IMapper mapper,
            BaseRezervacijaState baseRezervacijaState, IRezervacijaValidator rezervacijaValidator) : base(context, mapper)
        {
            _baseRezervacijaState = baseRezervacijaState;
            _rezervacijaValidator = rezervacijaValidator;
        }


        public override IQueryable<Database.Rezervacija> AddFilter(RezervacijaSearchObject search, IQueryable<Database.Rezervacija> query)
        {
            query = base.AddFilter(search, query);


            if (search.KorisnikId != null)
            {
                query = query.Where(x => x.KorisnikId == search.KorisnikId);
            }

            if (search.FrizerId != null)
            {
                query = query.Where(x => x.FrizerId == search.FrizerId);
            }

            if (!string.IsNullOrWhiteSpace(search.Sifra))
            {
                query = query.Where(x => x.Sifra.ToLower().Contains(search.Sifra.ToLower()));
            }

            if (search.DatumRezervacije != null)
            {
                query = query.Where(x => x.DatumRezervacije.Date == search.DatumRezervacije.Value.Date);
            }

            if (search.DatumRezervacijeGTE != null)
            {
                query = query.Where(x => x.DatumRezervacije >= search.DatumRezervacijeGTE);
            }

            if (search.DatumRezervacijeLTE != null)
            {
                query = query.Where(x => x.DatumRezervacije <= search.DatumRezervacijeLTE);
            }

            if (search.NacinPlacanjaId != null)
            {
                query = query.Where(x => x.NacinPlacanjaId == search.NacinPlacanjaId);
            }

            if (search.UkupnaCijena != null)
            {
                query = query.Where(x => x.UkupnaCijena == search.UkupnaCijena);
            }

            if (search.StateMachine != null && search.StateMachine.Any())
            {
                query = query.Where(x => x.StateMachine != null && search.StateMachine.Contains(x.StateMachine));
            }

            if (search?.IsDeleted != null)
            {
                query = query.Where(x => x.IsDeleted == search.IsDeleted);
            }

            return query;

        }

        public override async Task<Model.Rezervacija> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
         
            var rezervacija = await Context.Rezervacijas
                .Include(r => r.Korisnik).Include(r=>r.Frizer)
                .Include(r => r.NacinPlacanja)
                .Include(r => r.StavkeRezervacijes)
                .ThenInclude(sr => sr.Usluga)
                .Include(r => r.AktiviranaPromocija).ThenInclude(ap => ap.Promocija)
                .FirstOrDefaultAsync(k => k.RezervacijaId == id && !k.IsDeleted, cancellationToken);


            if (rezervacija == null)
                throw new UserException("Uneseni ID ne postoji.");

            var dto = Mapper.Map<Model.Rezervacija>(rezervacija);

            if (rezervacija.Frizer != null)
                dto.FrizerImePrezime = $"{rezervacija.Frizer.Ime} {rezervacija.Frizer.Prezime}";

            if (rezervacija.Korisnik != null)
                dto.KlijentImePrezime = $"{rezervacija.Korisnik.Ime} {rezervacija.Korisnik.Prezime}";

            if (rezervacija.NacinPlacanja != null)
                dto.NacinPlacanjaNaziv = rezervacija.NacinPlacanja.Naziv;

            if (rezervacija.AktiviranaPromocija != null)
                dto.AktiviranaPromocijaNaziv = rezervacija.AktiviranaPromocija.Promocija.Naziv; 

            dto.StavkeRezervacijes = rezervacija.StavkeRezervacijes
           .Where(sr => !sr.IsDeleted && sr.Usluga != null && !sr.Usluga.IsDeleted)
           .Select(sr => new Model.StavkeRezervacije
              {
                  StavkeRezervacijeId = sr.StavkeRezervacijeId,
                  RezervacijaId = sr.RezervacijaId,
                  UslugaId = sr.UslugaId,
                  Cijena = sr.Cijena,
                  UslugaNaziv = sr.Usluga.Naziv,
                  Trajanje = sr.Usluga.Trajanje,
                  OriginalnaCijena = sr.Usluga.Cijena,
                  Slika=sr.Usluga.Slika
           }).ToList();

            return dto;
        }


        public override async Task<PagedResult<Model.Rezervacija>> GetPagedAsync(RezervacijaSearchObject search, CancellationToken cancellationToken = default)
        {
            var query = Context.Rezervacijas
              .Include(n => n.Korisnik).Include(r => r.Frizer)
              .Include(n => n.NacinPlacanja)
              .Include(n => n.StavkeRezervacijes).ThenInclude(sr => sr.Usluga)
              .Include(r => r.AktiviranaPromocija).ThenInclude(ap => ap.Promocija).Where(r => !r.IsDeleted); 

            query = AddFilter(search, query);

            int count = await query.CountAsync(cancellationToken);

            if (!string.IsNullOrEmpty(search?.OrderBy) && !string.IsNullOrEmpty(search?.SortDirection))
            {
                query = ApplySorting(query, search.OrderBy, search.SortDirection);
            }

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync(cancellationToken);

            var result = Mapper.Map<List<Model.Rezervacija>>(list);

            for (int i = 0; i < result.Count; i++)
            {
                var rezervacija = list[i];

                if (rezervacija.Frizer != null)
                    result[i].FrizerImePrezime = $"{rezervacija.Frizer.Ime} {rezervacija.Frizer.Prezime}";

                if (rezervacija.Korisnik != null)
                    result[i].KlijentImePrezime = $"{rezervacija.Korisnik.Ime} {rezervacija.Korisnik.Prezime}";

                if (rezervacija.NacinPlacanja != null)
                    result[i].NacinPlacanjaNaziv = rezervacija.NacinPlacanja.Naziv;

                if (rezervacija.AktiviranaPromocija != null)
                    result[i].AktiviranaPromocijaNaziv = rezervacija.AktiviranaPromocija.Promocija.Naziv;



    // result[i].StavkeRezervacijes = list[i].StavkeRezervacijes
    //.Where(sr => !sr.IsDeleted && sr.Usluga != null && !sr.Usluga.IsDeleted)
    //.Select(sr => new Model.StavkeRezervacije
    //{
    //    StavkeRezervacijeId = sr.StavkeRezervacijeId,
    //    RezervacijaId = sr.RezervacijaId,
    //    UslugaId = sr.UslugaId,
    //    Cijena = sr.Cijena,
    //    UslugaNaziv = sr.Usluga.Naziv,
    //    Trajanje = sr.Usluga.Trajanje,
    //    OriginalnaCijena = sr.Usluga.Cijena,
    //    Slika = sr.Usluga.Slika,
    //   // ImaPopust = sr.Cijena.HasValue && sr.Cijena < sr.Usluga.Cijena
    //}).ToList();



            }
            return new PagedResult<Model.Rezervacija>
            {
                ResultList = result,
                Count = count
            };
        }

        public override async Task<Model.Rezervacija> InsertAsync(RezervacijaInsertRequest request, CancellationToken cancellationToken = default)
        {
            var state = _baseRezervacijaState.CreateState("initial");
            return await state.Insert(request, cancellationToken);
        }

        public override async Task<Model.Rezervacija> UpdateAsync(int rezervacijaId, RezervacijaUpdateRequest request, CancellationToken cancellationToken = default)
        {
            var entity = await Context.Rezervacijas.FindAsync(new object[] { rezervacijaId }, cancellationToken)
                ?? throw new UserException("Pogrešan ID rezervacije.");

            if (string.IsNullOrEmpty(entity.StateMachine))
                throw new UserException("State nije definiran za ovu rezervaciju.");

            var state = _baseRezervacijaState.CreateState(entity.StateMachine);
            return await state.Update(rezervacijaId, request, cancellationToken);
        }

        public async Task<Model.Rezervacija> OdobriAsync(int rezervacijaId, int frizerId, CancellationToken cancellationToken = default)
        {
            var rezervacija = await Context.Rezervacijas.FindAsync(new object[] { rezervacijaId }, cancellationToken)
                ?? throw new UserException("Pogrešan ID rezervacije.");

            if (string.IsNullOrEmpty(rezervacija.StateMachine))
                throw new UserException("State nije definiran za ovu rezervaciju.");

            var state = _baseRezervacijaState.CreateState(rezervacija.StateMachine);
            return await state.Odobrena(rezervacijaId, frizerId, cancellationToken);
        }

        public async Task<Model.Rezervacija> ZavrsiAsync(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            var rezervacija = await Context.Rezervacijas.FindAsync(new object[] { rezervacijaId }, cancellationToken)
                ?? throw new UserException("Pogrešan ID rezervacije.");

            if (string.IsNullOrEmpty(rezervacija.StateMachine))
                throw new UserException("State nije definiran za ovu rezervaciju.");

            var datumIVrijeme = rezervacija.DatumRezervacije.Date + rezervacija.VrijemePocetka;
            var trenutnoVrijeme = DateTime.Now;

            if (datumIVrijeme > trenutnoVrijeme)
                throw new UserException("Rezervacija još nije izvršena. Može se označiti kao završena tek nakon završetka termina.");

            var state = _baseRezervacijaState.CreateState(rezervacija.StateMachine);
            return await state.Zavrsena(rezervacijaId, cancellationToken);
        }

        public async Task<Model.Rezervacija> PonistiAsync(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            var rezervacija = await Context.Rezervacijas.FindAsync(new object[] { rezervacijaId }, cancellationToken)
                 ?? throw new UserException("Pogrešan ID rezervacije.");

            if (string.IsNullOrEmpty(rezervacija.StateMachine))
                throw new UserException("State nije definiran za ovu rezervaciju.");

            var state = _baseRezervacijaState.CreateState(rezervacija.StateMachine);
            return await state.Ponistena(rezervacijaId, cancellationToken);
        }

        public async Task<List<string>> AllowedActionsAsync(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            var rezervacija = await Context.Rezervacijas.FindAsync(new object[] { rezervacijaId }, cancellationToken)
                ?? throw new UserException("Pogrešan ID rezervacije.");

            if (string.IsNullOrEmpty(rezervacija.StateMachine))
                throw new UserException("State nije definiran za ovu rezervaciju.");

            var state = _baseRezervacijaState.CreateState(rezervacija.StateMachine);
            return state.AllowedActions(rezervacija);
        }

        public async Task<string> ProvjeriTerminAsync(RezervacijaInsertRequest rezervacija, CancellationToken cancellationToken = default)
        {
            await _rezervacijaValidator.ValidateInsertAsync(rezervacija, cancellationToken);

            var usluge = await Context.Uslugas
                .Where(u => rezervacija.StavkeRezervacije.Select(s => s.UslugaId).Contains(u.UslugaId) && !u.IsDeleted)
                .ToListAsync(cancellationToken);

            if (usluge.Count == 0)
                throw new UserException("Nijedna od izabranih usluga nije validna.");

            var ukupnoTrajanje = usluge.Sum(u => u.Trajanje);
            var vrijemeKraja = rezervacija.VrijemePocetka.Add(TimeSpan.FromMinutes(ukupnoTrajanje));

            var pocetakRadnogVremena = new TimeSpan(8, 0, 0);
            var krajRadnogVremena = new TimeSpan(16, 0, 0);

            if (rezervacija.VrijemePocetka < pocetakRadnogVremena || vrijemeKraja > krajRadnogVremena)
                throw new UserException("Odabrani termin izlazi izvan radnog vremena frizera (08:00 - 16:00).");

            var kolidira = await Context.Rezervacijas
                .Where(r =>
                    r.FrizerId == rezervacija.FrizerId &&
                    r.DatumRezervacije.Date == rezervacija.DatumRezervacije.Date &&
                    !r.IsDeleted &&
                     r.TerminZatvoren &&
                    (
                        (rezervacija.VrijemePocetka >= r.VrijemePocetka && rezervacija.VrijemePocetka < r.VrijemeKraja) ||
                        (vrijemeKraja > r.VrijemePocetka && vrijemeKraja <= r.VrijemeKraja) ||
                        (rezervacija.VrijemePocetka <= r.VrijemePocetka && vrijemeKraja >= r.VrijemeKraja)
                    )
                )
                .AnyAsync(cancellationToken);

            if (kolidira)
                throw new UserException("Odabrani termin nije dostupan za izabrane usluge.");

            return "Termin je slobodan.";
        }

        public async Task<List<(TimeSpan VrijemePocetka, TimeSpan VrijemeKraja)>> GetZauzetiTerminiZaDatumAsync(DateTime datumRezervacije, int frizerId, CancellationToken cancellationToken = default)
        {
            var termini = await Context.Rezervacijas
                .Where(r => r.DatumRezervacije.Date == datumRezervacije.Date
                            && r.FrizerId == frizerId
                            && !r.IsDeleted
                            && r.TerminZatvoren)
                .Select(r => new { r.VrijemePocetka, r.VrijemeKraja })
                .ToListAsync(cancellationToken);

            return termini.Select(r => (r.VrijemePocetka, r.VrijemeKraja ?? TimeSpan.Zero)).ToList();
        }

        public async Task<List<object>> GetKalendarAsync(int frizerId, int godina, int mjesec, CancellationToken cancellationToken = default)
        {
            List<object> rezultat = new List<object>();
            int brojDana = DateTime.DaysInMonth(godina, mjesec);

            TimeSpan minTrajanjeUsluge = TimeSpan.FromMinutes(10); 

            for (int dan = 1; dan <= brojDana; dan++)
            {
                var date = new DateTime(godina, mjesec, dan);

                if (date.DayOfWeek == DayOfWeek.Sunday)
                {
                    rezultat.Add(new { datum = date.ToString("yyyy-MM-dd"), status = "neradni_dan" });
                    continue;
                }

                var termini = await GetZauzetiTerminiZaDatumAsync(date, frizerId, cancellationToken);

                if (termini.Count == 0)
                {
                    rezultat.Add(new { datum = date.ToString("yyyy-MM-dd"), status = "slobodan" });
                    continue;
                }

                var min = new TimeSpan(8, 0, 0);
                var max = new TimeSpan(16, 0, 0);

                bool fullBusy = ProvjeriPokrivenostDana(termini, min, max);

                if (!fullBusy)
                {

                    bool postojiRupa = false;

                    var sorted = termini.OrderBy(t => t.VrijemePocetka).ToList();
                    TimeSpan trenutni = min;

                    foreach (var (VrijemePocetka, VrijemeKraja) in sorted)
                    {
                        if ((VrijemePocetka - trenutni) >= minTrajanjeUsluge)
                        {
                            postojiRupa = true;
                            break;
                        }
                        if (VrijemeKraja > trenutni)
                            trenutni = VrijemeKraja;
                    }

                    if (!postojiRupa && (max - trenutni) >= minTrajanjeUsluge)
                    {
                        postojiRupa = true;
                    }

                    fullBusy = !postojiRupa;
                }

                rezultat.Add(new
                {
                    datum = date.ToString("yyyy-MM-dd"),
                    status = fullBusy ? "zauzet" : "djelomicno"
                });
            }

            return rezultat;
        }

        private bool ProvjeriPokrivenostDana(List<(TimeSpan VrijemePocetka, TimeSpan VrijemeKraja)> intervali, TimeSpan pocetakDana, TimeSpan krajDana)
        {
            var sorted = intervali.OrderBy(i => i.VrijemePocetka).ToList();
            TimeSpan trenutni = pocetakDana;

            foreach (var (VrijemePocetka, VrijemeKraja) in sorted)
            {
                if (VrijemePocetka > trenutni)
                    return false; 

                if (VrijemeKraja > trenutni)
                    trenutni = VrijemeKraja;
            }

            return trenutni >= krajDana;
        }


    }
}



