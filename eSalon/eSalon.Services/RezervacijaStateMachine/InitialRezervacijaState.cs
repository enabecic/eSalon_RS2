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

        public InitialRezervacijaState(ESalonContext context, IMapper mapper, IServiceProvider serviceProvider, 
            IRezervacijaValidator rezervacijaValidator, ICodeGenerator codeGenerator, IUslugaValidator uslugaValidator) : base(context, mapper, serviceProvider)
        {
            _codeGenerator = codeGenerator;
            _rezervacijaValidator = rezervacijaValidator;
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

            var pocetakRadnogVremena = new TimeSpan(8, 0, 0); 
            var krajRadnogVremena = new TimeSpan(16, 0, 0);   

            if (rezervacija.VrijemePocetka < pocetakRadnogVremena || vrijemeKraja > krajRadnogVremena)
            {
                throw new UserException("Usluge ne mogu stati u odabrani termin jer izlaze izvan radnog vremena (08:00 - 16:00).");
            }

            var kolidira = await Context.Rezervacijas
                .Where(r =>
                    r.FrizerId == rezervacija.FrizerId &&
                    r.DatumRezervacije.Date == rezervacija.DatumRezervacije.Date &&
                    !r.IsDeleted &&
                    (
                        (rezervacija.VrijemePocetka >= r.VrijemePocetka && rezervacija.VrijemePocetka < r.VrijemeKraja) ||
                        (vrijemeKraja > r.VrijemePocetka && vrijemeKraja <= r.VrijemeKraja) ||
                        (rezervacija.VrijemePocetka <= r.VrijemePocetka && vrijemeKraja >= r.VrijemeKraja)
                    )
                ).AnyAsync(cancellationToken);

            if (kolidira)
            {
                throw new UserException("Odabrani termin nije dostupan za izabrane usluge.");
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

                var danas = DateTime.Now;
                if (aktivirana.Promocija.DatumPocetka > danas || aktivirana.Promocija.DatumKraja < danas)
                    throw new UserException("Promocija nije aktivna u ovom periodu.");

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

            return Mapper.Map<Model.Rezervacija>(entity);
        }


        public override List<string> AllowedActions(Rezervacija entity)
        {
            return new List<string> { nameof(Insert) };
        }

    }
}
