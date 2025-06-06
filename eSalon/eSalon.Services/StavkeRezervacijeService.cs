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
    public class StavkeRezervacijeService : BaseCRUDServiceAsync<Model.StavkeRezervacije, StavkeRezervacijeSearchObject, Database.StavkeRezervacije, StavkeRezervacijeInsertRequest, StavkeRezervacijeUpdateRequest>, IStavkeRezervacijeService
    {
        public StavkeRezervacijeService(ESalonContext context, IMapper mapper) : base(context, mapper)
        {
        }


        public override IQueryable<StavkeRezervacije> AddFilter(StavkeRezervacijeSearchObject search, IQueryable<StavkeRezervacije> query)
        {
            query = base.AddFilter(search, query);

            if (search.CijenaGTE != null)
                query = query.Where(x => x.Cijena >= search.CijenaGTE);

            if (search.CijenaLTE != null)
                query = query.Where(x => x.Cijena <= search.CijenaLTE);

            if (search.RezervacijaId != null)
                query = query.Where(x => x.RezervacijaId == search.RezervacijaId);

            if (search.UslugaId != null)
                query = query.Where(x => x.UslugaId == search.UslugaId);

            if (search?.IsDeleted != null)
            {
                query = query.Where(x => x.IsDeleted == search.IsDeleted);
            }

            return query;
        }


        public override async Task<Model.PagedResult<Model.StavkeRezervacije>> GetPagedAsync(StavkeRezervacijeSearchObject search, CancellationToken cancellationToken = default)
        {
            var query = Context.StavkeRezervacijes.Include(s => s.Usluga).Where(s => !s.IsDeleted);

            query = AddFilter(search, query);

            int count = await query.CountAsync(cancellationToken);

            if (!string.IsNullOrEmpty(search?.OrderBy) &&
                !string.IsNullOrEmpty(search?.SortDirection))
            {
                query = ApplySorting(query, search.OrderBy, search.SortDirection);
            }

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync(cancellationToken);

            var result = new List<Model.StavkeRezervacije>();
            result = Mapper.Map(list, result);

            for (int i = 0; i < result.Count; i++)
            {
                var usluga = list[i].Usluga;
                if (usluga is null) continue;

                result[i].UslugaNaziv = usluga.Naziv;
                result[i].Slika = usluga.Slika;
                result[i].Trajanje = usluga.Trajanje;
                result[i].OriginalnaCijena = usluga.Cijena;
            }

            return new Model.PagedResult<Model.StavkeRezervacije>
            {
                ResultList = result,
                Count = count
            };
        }

    }
}
