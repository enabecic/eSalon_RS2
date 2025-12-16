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
    public class OdobrenaRezervacijaState : BaseRezervacijaState
    {
        private readonly IObavijestService _obavijestService;
        public OdobrenaRezervacijaState(ESalonContext context, IMapper mapper, IServiceProvider serviceProvider, IObavijestService obavijestService) : base(context, mapper, serviceProvider)
        {
            _obavijestService = obavijestService;
        }

        public override async Task<Model.Rezervacija> Zavrsena(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            var set = Context.Set<Database.Rezervacija>();
            var entity = await set.FindAsync(new object[] { rezervacijaId }, cancellationToken);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            entity.StateMachine = "zavrsena";
            await Context.SaveChangesAsync(cancellationToken);

            return Mapper.Map<Model.Rezervacija>(entity);
        }

        public override async Task<Model.Rezervacija> Ponistena(int rezervacijaId, int korisnikId, CancellationToken cancellationToken = default)
        {
            var set = Context.Set<Database.Rezervacija>();
            var entity = await set.FindAsync(new object[] { rezervacijaId }, cancellationToken);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena");

            entity.StateMachine = "ponistena";

            if (korisnikId == entity.KorisnikId)
            {
                entity.TerminZatvoren = false;

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
                            $"Rezervacija sa šifrom #{entity.Sifra} koju ste imali u rasporedu dana " +
                            $"{entity.DatumRezervacije:dd.MM.yyyy} je otkazana od strane klijenta.\n\n" +
                            "Hvala,\nVaš eSalon tim"
                    };

                    await _obavijestService.InsertAsync(obavijest, cancellationToken);
                }
            }
            else if (korisnikId == entity.FrizerId)
            {
                var klijent = await Context.Korisniks
                    .FirstOrDefaultAsync(k => k.KorisnikId == entity.KorisnikId && !k.IsDeleted, cancellationToken);

                if (klijent != null)
                {
                    var obavijest = new ObavijestInsertRequest
                    {
                        KorisnikId = klijent.KorisnikId,
                        Naslov = "Rezervacija je otkazana",
                        Sadrzaj =
                            $"Poštovanje {klijent.Ime},\n\n" +
                            $"Nažalost, Vaša rezervacija sa šifrom #{entity.Sifra}, zakazana za " +
                            $"{entity.DatumRezervacije:dd.MM.yyyy}, je otkazana od strane frizera. " +
                            "Iskreno nam je žao zbog ove promjene i nadamo se da ćemo Vas uskoro moći ugostiti u našem salonu i pružiti Vam vrhunsku uslugu.\n\n" +
                            "Hvala na razumijevanju,\nVaš eSalon tim"
                    };

                    await _obavijestService.InsertAsync(obavijest, cancellationToken);
                }
            }

            await Context.SaveChangesAsync(cancellationToken);

            return Mapper.Map<Model.Rezervacija>(entity);
        }

        public override List<string> AllowedActions(Rezervacija entity)
        {
            return new List<string>() { nameof(Zavrsena), nameof(Ponistena) };
        }
    }
}
