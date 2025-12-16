using Azure.Core;
using eSalon.Model.Exceptions;
using eSalon.Model.Requests;
using eSalon.Services.Database;
using eSalon.Services.Helpers;
using eSalon.Services.Validator.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.RezervacijaStateMachine
{
    public class InitialRezervacijaState : BaseRezervacijaState
    {
        private readonly IRezervacijaValidator _rezervacijaValidator;
        private readonly ICodeGenerator _codeGenerator;
        private readonly IObavijestService _obavijestService;

        public InitialRezervacijaState(ESalonContext context, IMapper mapper, IServiceProvider serviceProvider, 
            IRezervacijaValidator rezervacijaValidator, ICodeGenerator codeGenerator, IUslugaValidator uslugaValidator, IObavijestService obavijestService) : base(context, mapper, serviceProvider)
        {
            _codeGenerator = codeGenerator;
            _rezervacijaValidator = rezervacijaValidator;
            _obavijestService = obavijestService;
        }

        public override async Task<Model.Rezervacija> Insert(RezervacijaInsertRequest rezervacija, CancellationToken cancellationToken = default)
        {
            await _rezervacijaValidator.ValidateInsertAsync(rezervacija, cancellationToken);

            var entity = Mapper.Map<Database.Rezervacija>(rezervacija);


            

            var usluge = await Context.Uslugas
               .Where(u => rezervacija.StavkeRezervacije.Select(s => s.UslugaId).Contains(u.UslugaId) && !u.IsDeleted)
               .ToListAsync(cancellationToken);

            var ukupnoTrajanje = usluge.Sum(u => u.Trajanje);
            var vrijemeKraja = rezervacija.VrijemePocetka.Add(TimeSpan.FromMinutes(ukupnoTrajanje));

            var pauzaPocetak = new TimeSpan(12, 0, 0);
            var pauzaKraj = new TimeSpan(12, 30, 0);

            bool ulaziUPauzu =
                (rezervacija.VrijemePocetka < pauzaKraj && vrijemeKraja > pauzaPocetak);

            if (ulaziUPauzu)
            {
                throw new UserException("Termin se ne može rezervisati jer frizer ima pauzu (12:00–12:30). Provjerite drugi termin.");
            }

            var pocetakRadnogVremena = new TimeSpan(8, 0, 0); 
            var krajRadnogVremena = new TimeSpan(16, 0, 0);   

            if (rezervacija.VrijemePocetka < pocetakRadnogVremena || vrijemeKraja > krajRadnogVremena)
            {
                throw new UserException("Usluge ne mogu stati u odabrani termin jer izlaze izvan radnog vremena (08:00 - 16:00). Provjerite drugi termin.");
            }

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
                ).AnyAsync(cancellationToken);

            if (kolidira)
            {
                throw new UserException("Odabrani termin nije dostupan za izabrane usluge. Provjerite drugi termin.");
            }

            entity.VrijemeKraja = vrijemeKraja;
            entity.UkupanBrojUsluga = usluge.Count;
            entity.UkupnoTrajanje = ukupnoTrajanje;

            if (!string.IsNullOrWhiteSpace(rezervacija.KodPromocije))
            {
                var aktivirana = await Context.AktiviranaPromocijas
                    .Include(x => x.Promocija)
                    .FirstOrDefaultAsync(x =>
                        x.KorisnikId == rezervacija.KorisnikId &&
                        x.Promocija != null &&                    
                        !x.Promocija.IsDeleted &&       //        
                        x.Promocija.Kod == rezervacija.KodPromocije &&
                        x.Aktivirana &&
                        !x.Iskoristena &&
                        !x.IsDeleted, //
                        cancellationToken);

                if (aktivirana == null)
                    throw new UserException("Kod nije validan, nije aktiviran ili je već iskorišten.");

                var danas = DateTime.Now.Date;
                if (aktivirana.Promocija.DatumPocetka.Date > danas || aktivirana.Promocija.DatumKraja.Date < danas)
                    throw new UserException("Kod nije validan jer promocija nije aktivna u ovom periodu.");

                var uslugaPromocijeID = aktivirana.Promocija.UslugaId;
                var stavkeUslugeIds = rezervacija.StavkeRezervacije.Select(x => x.UslugaId).ToList();

                if (!stavkeUslugeIds.Contains(uslugaPromocijeID))
                    throw new UserException("Promocija se ne može primijeniti na odabrane usluge.");

                var ukupnaCijenaBezPopusta = usluge.Sum(u => u.Cijena);
                var uslugaPromocije = usluge.FirstOrDefault(u => u.UslugaId == uslugaPromocijeID);

                var popustt = aktivirana.Promocija.Popust;
                var iznosPopusta = uslugaPromocije != null ? uslugaPromocije.Cijena * popustt / 100 : 0;
                var cijenaSaPopustom = ukupnaCijenaBezPopusta - iznosPopusta;

                entity.UkupnaCijena = cijenaSaPopustom;
                entity.AktiviranaPromocijaId = aktivirana.AktiviranaPromocijaId;
                aktivirana.Iskoristena = true;
            }
            else
            {
                entity.UkupnaCijena = usluge.Sum(u => u.Cijena);
            }

            entity.IsDeleted = false;
            entity.TerminZatvoren = true;

            entity.Sifra = await _codeGenerator.GenerateUniqueCodeAsync(
                async kod => await Context.Promocijas.AnyAsync(p => p.Kod == kod));

            entity.StateMachine = "kreirana";

            


            Context.Rezervacijas.Add(entity);
            await Context.SaveChangesAsync(cancellationToken);


            

            decimal? popust = null;
            int? uslugaPromocijeId = null;

            if (entity.AktiviranaPromocijaId.HasValue)
            {
                var aktivirana = await Context.AktiviranaPromocijas
                    .Include(x => x.Promocija)
                   .FirstOrDefaultAsync(x =>
                        x.AktiviranaPromocijaId == entity.AktiviranaPromocijaId &&
                        x.Promocija != null &&
                        !x.Promocija.IsDeleted &&
                        !x.IsDeleted, //
                        cancellationToken);

                if (aktivirana != null && aktivirana.Promocija != null)
                {
                    popust = aktivirana.Promocija.Popust;
                    uslugaPromocijeId = aktivirana.Promocija.UslugaId;

                    aktivirana.Iskoristena = true;
                }
            }

            if (rezervacija.StavkeRezervacije != null && rezervacija.StavkeRezervacije.Count > 0)
            {
                foreach (var stavka in rezervacija.StavkeRezervacije)
                {
                    var usluga = await Context.Uslugas
                        .Where(u => u.UslugaId == stavka.UslugaId && !u.IsDeleted)
                        .FirstOrDefaultAsync(cancellationToken);

                    if (usluga == null)
                        throw new UserException("Usluga nije pronađena.");

                    decimal cijenaZaSpasiti = usluga.Cijena;

                    if (popust.HasValue && uslugaPromocijeId.HasValue && stavka.UslugaId == uslugaPromocijeId.Value)
                    {
                        cijenaZaSpasiti = usluga.Cijena - (usluga.Cijena * popust.Value / 100);
                    }

                    var novaStavka = new Database.StavkeRezervacije
                    {
                        RezervacijaId = entity.RezervacijaId,
                        UslugaId = stavka.UslugaId,
                        Cijena = cijenaZaSpasiti,
                        IsDeleted = false
                    };

                    await Context.StavkeRezervacijes.AddAsync(novaStavka, cancellationToken);
                }
            }




                await Context.SaveChangesAsync(cancellationToken);

            var frizer = await Context.Korisniks
                .FirstOrDefaultAsync(f => f.KorisnikId == entity.FrizerId && !f.IsDeleted, cancellationToken);

            if (frizer != null)
            {
                var obavijest = new ObavijestInsertRequest
                {
                    KorisnikId = entity.FrizerId,
                    Naslov = "Nova rezervacija",
                    Sadrzaj =
                        $"Poštovanje {frizer.Ime},\n\n" +
                        $"Kreirana je nova rezervacija #{entity.Sifra} za datum {entity.DatumRezervacije:dd.MM.yyyy}.\n" +
                        "Molimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\n" +
                        "Hvala,\nVaš eSalon tim"
                };

                await _obavijestService.InsertAsync(obavijest, cancellationToken);
            }

            return Mapper.Map<Model.Rezervacija>(entity);
        }


        public override List<string> AllowedActions(Rezervacija entity)
        {
            return new List<string> { nameof(Insert) };
        }

    }
}
