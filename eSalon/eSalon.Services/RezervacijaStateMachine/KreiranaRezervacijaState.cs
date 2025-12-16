using Azure.Core;
using eSalon.Model.Exceptions;
using eSalon.Model.Requests;
using eSalon.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.RezervacijaStateMachine
{
    public class KreiranaRezervacijaState : BaseRezervacijaState
    {
        private readonly IObavijestService _obavijestService;
        public KreiranaRezervacijaState(ESalonContext context, IMapper mapper, IServiceProvider serviceProvider, IObavijestService obavijestService) : base(context, mapper, serviceProvider)
        {
            _obavijestService = obavijestService;
        }

        public override async Task<Model.Rezervacija> Update(int rezervacijaId, RezervacijaUpdateRequest rezervacija, CancellationToken cancellationToken = default)
        {
            var set = Context.Set<Database.Rezervacija>();
            var entity = await set.FindAsync(new object[] { rezervacijaId }, cancellationToken);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena");

            Mapper.Map(rezervacija, entity);
            await Context.SaveChangesAsync(cancellationToken);

            return Mapper.Map<Model.Rezervacija>(entity);
        }

      

        public override async Task<Model.Rezervacija> Odobrena(int rezervacijaId, int frizerId,CancellationToken cancellationToken = default) 
        {
            var set = Context.Set<Database.Rezervacija>();
            var entity = await set.FindAsync(new object[] { rezervacijaId }, cancellationToken);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena");

            if (entity.FrizerId != frizerId)
                throw new UserException("Samo frizer kojem je rezervacija dodijeljena može je odobriti.");

            entity.StateMachine = "odobrena";
            await Context.SaveChangesAsync(cancellationToken);

            var korisnik = await Context.Korisniks
                .FirstOrDefaultAsync(k => k.KorisnikId == entity.KorisnikId && !k.IsDeleted, cancellationToken);

            var frizer = await Context.Korisniks
                .FirstOrDefaultAsync(f => f.KorisnikId == entity.FrizerId && !f.IsDeleted, cancellationToken);

            var frizerIme = frizer != null ? $"{frizer.Ime} {frizer.Prezime}" : "od strane frizera";


            if (korisnik != null)
            {
                var obavijest = new ObavijestInsertRequest
                {
                    KorisnikId = korisnik.KorisnikId,
                    Naslov = "Vaša rezervacija je odobrena",
                    Sadrzaj =
                        $"Poštovanje {korisnik.Ime},\n\n" +
                        "Vaša rezervacija u salonu je odobrena od strane frizera " + frizerIme + ". " +
                        "Molimo Vas da planirate dolazak prema odabranom terminu.\n\n" +
                        $"Detalji rezervacije:\n" +
                        $"- Šifra rezervacije: #{entity.Sifra}\n" +
                        $"- Klijent: {korisnik.Ime} {korisnik.Prezime}\n" +
                        $"- Frizer: {frizerIme}\n" +
                        $"- Datum rezervacije: {entity.DatumRezervacije:dd.MM.yyyy}\n" +
                        $"- Vrijeme rezervacije: {entity.VrijemePocetka:hh\\:mm} - {entity.VrijemeKraja:hh\\:mm}\n" +
                        $"- Broj usluga: {entity.UkupanBrojUsluga}\n" +
                        $"- Ukupan iznos: {entity.UkupnaCijena} KM\n\n" +
                        "Hvala na rezervaciji!\n" +
                        "Vaš eSalon tim"
                };

                await _obavijestService.InsertAsync(obavijest, cancellationToken);
            }

            return Mapper.Map<Model.Rezervacija>(entity);
        }


        public override async Task<Model.Rezervacija> Ponistena(int rezervacijaId, int korisnikId, CancellationToken cancellationToken = default)
        {
            var set = Context.Set<Database.Rezervacija>();
            var entity = await set.FindAsync(new object[] { rezervacijaId }, cancellationToken);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena");

            entity.StateMachine = "ponistena";
            entity.TerminZatvoren = false;
            await Context.SaveChangesAsync(cancellationToken);

            var frizer = await Context.Korisniks
                .FirstOrDefaultAsync(f => f.KorisnikId == entity.FrizerId && !f.IsDeleted, cancellationToken);

            if (frizer != null)
            {
                var obavijest = new ObavijestInsertRequest
                {
                    KorisnikId = frizer.KorisnikId,
                    Naslov = "Rezervacija je otkazana",
                    Sadrzaj =
                        $"Poštovanje {frizer.Ime},\n\n" +
                        $"Rezervacija sa šifrom #{entity.Sifra} koju ste imali u rasporedu dana {entity.DatumRezervacije:dd.MM.yyyy} je otkazana od strane klijenta.\n\n" +
                        "Hvala,\nVaš eSalon tim"
                };

                await _obavijestService.InsertAsync(obavijest, cancellationToken);
            }

            return Mapper.Map<Model.Rezervacija>(entity);
        }


        public override List<string> AllowedActions(Rezervacija entity)
        {
            return new List<string>() { nameof(Update), nameof(Odobrena), nameof(Ponistena) };
        }

    }
}
