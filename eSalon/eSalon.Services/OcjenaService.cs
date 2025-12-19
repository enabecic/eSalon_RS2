using eSalon.Model.Exceptions;
using eSalon.Model.Requests;
using eSalon.Model.SearchObjects;
using eSalon.Services.BaseServicesImplementation;
using eSalon.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services
{
    public class OcjenaService : BaseCRUDServiceAsync<Model.Ocjena, OcjenaSearchObject, Database.Ocjena, OcjenaInsertRequest, OcjenaUpdateRequest>, IOcjenaService
    {
        public OcjenaService(ESalonContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Ocjena> AddFilter(OcjenaSearchObject search, IQueryable<Ocjena> query)
        {
            query = base.AddFilter(search, query);

            if (search.VrijednostGTE != null)
            {
                query = query.Where(x => x.Vrijednost >= search.VrijednostGTE);
            }

            if (search.VrijednostLTE != null)
            {
                query = query.Where(x => x.Vrijednost <= search.VrijednostLTE);
            }

            if (search.DatumOcjenjivanjaGTE != null)
            {
                query = query.Where(x => x.DatumOcjenjivanja >= search.DatumOcjenjivanjaGTE);
            }

            if (search.DatumOcjenjivanjaLTE != null)
            {
                query = query.Where(x => x.DatumOcjenjivanja <= search.DatumOcjenjivanjaLTE);
            }

            if (search.KorisnikId != null)
            {
                query = query.Where(x => x.KorisnikId == search.KorisnikId);
            }

            if (search.UslugaId != null)
            {
                query = query.Where(x => x.UslugaId == search.UslugaId);
            }

            if (search.IsDeleted != null)
            {
                query = query.Where(x => x.UslugaId == search.UslugaId);
            }

            return query;
        }

        public override async Task BeforeInsertAsync(OcjenaInsertRequest request, Ocjena entity, CancellationToken cancellationToken = default)
        {
            var postojiOcjena = await Context.Ocjenas
                .AnyAsync(x => x.KorisnikId == request.KorisnikId && x.UslugaId == request.UslugaId && !x.IsDeleted, cancellationToken);

            if (postojiOcjena)
            {
                throw new UserException("Već ste ocijenili ovu uslugu.");
            }

            var imaRezervaciju = await Context.Rezervacijas
          .Where(r => r.KorisnikId == request.KorisnikId && !r.IsDeleted && r.StateMachine == "zavrsena")
           .AnyAsync(r => r.StavkeRezervacijes.Any(sr => sr.UslugaId == request.UslugaId), cancellationToken);

            if (!imaRezervaciju)
            {
                throw new UserException("Možete ocijeniti samo usluge koje ste prethodno rezervisali i koje su Vam pružene.");
            }

            entity.IsDeleted = false;

            await base.BeforeInsertAsync(request, entity, cancellationToken);
        }

    }
}
