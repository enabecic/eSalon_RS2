using eSalon.Model.Exceptions;
using eSalon.Model.Requests;
using eSalon.Model.SearchObjects;
using eSalon.Services.BaseServicesImplementation;
using eSalon.Services.Database;
using eSalon.Services.Validator.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services
{
    public class UlogaService : BaseCRUDServiceAsync<Model.Uloga, UlogaSearchObject, Database.Uloga, UlogaInsertRequest, UlogaUpdateRequest>, IUlogaService
    {

        private readonly IUlogaValidator _validator;

        public UlogaService(ESalonContext context, IMapper mapper , IUlogaValidator validator
            ) : base(context, mapper)
        {
            _validator = validator;
        }


        public override IQueryable<Uloga> AddFilter(UlogaSearchObject search, IQueryable<Database.Uloga> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.NazivGTE))
            {
                query = query.Where(x => x.Naziv.StartsWith(search.NazivGTE));
            }

            if (search?.IsDeleted != null)
            {
                query = query.Where(x => x.IsDeleted == search.IsDeleted);
            }

            return query;
        }

        
        public override async Task BeforeInsertAsync(UlogaInsertRequest request, Uloga entity, CancellationToken cancellationToken = default)
        {
            await _validator.ValidateInsertAsync(request, cancellationToken);

            entity.IsDeleted = false; 

            await base.BeforeInsertAsync(request, entity, cancellationToken);
        }


        public override async Task BeforeUpdateAsync(UlogaUpdateRequest request, Uloga entity, CancellationToken cancellationToken = default)
        {
            await _validator.ValidateEntityExistsAsync(entity.UlogaId, cancellationToken);
            await _validator.ValidateUpdateAsync(entity.UlogaId, request, cancellationToken);

            await base.BeforeUpdateAsync(request, entity, cancellationToken);

        }

        public override async Task BeforeDeleteAsync(Uloga entity, CancellationToken cancellationToken = default) 
        {
           

            bool uUpotrebi = await Context.KorisniciUloges
                .AnyAsync(x => x.UlogaId == entity.UlogaId && !x.IsDeleted, cancellationToken);

            if (uUpotrebi)
            {
                throw new UserException("Ova uloga je u upotrebi i ne može biti obrisana.");
            }

            await base.BeforeDeleteAsync(entity, cancellationToken);
        }

    }
}
