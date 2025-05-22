using eSalon.Model.Requests;
using eSalon.Model.SearchObjects;
using eSalon.Services.BaseServicesImplementation;
using eSalon.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services
{
    public class NacinPlacanjaService : BaseCRUDServiceAsync<Model.NacinPlacanja, NacinPlacanjaSearchObject, Database.NacinPlacanja, NacinPlacanjaInsertRequest, NacinPlacanjaIUpdateRequest>, INacinPlacanjaService
    {
        public NacinPlacanjaService(ESalonContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<NacinPlacanja> AddFilter(NacinPlacanjaSearchObject search, IQueryable<Database.NacinPlacanja> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.Naziv))
            {
                query = query.Where(x => x.Naziv.ToLower().Contains(search.Naziv.ToLower()));
            }
            if (search?.IsDeleted != null)
            {
                query = query.Where(x => x.IsDeleted == search.IsDeleted);
            }
            return query;
        }
    }
}
