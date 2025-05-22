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
    public class VrstaUslugeService : BaseCRUDServiceAsync<Model.VrstaUsluge, VrstaUslugeSearchObject, Database.VrstaUsluge, VrstaUslugeInsertRequest, VrstaUslugeUpdateRequest>, IVrstaUslugeService
    {
        private readonly IVrstaUslugeValidator _validator;
        public VrstaUslugeService(ESalonContext context, IMapper mapper, IVrstaUslugeValidator validator) : base(context, mapper)
        {
            _validator = validator;
        }

        public override IQueryable<VrstaUsluge> AddFilter(VrstaUslugeSearchObject search, IQueryable<Database.VrstaUsluge> query)
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


        public override async Task BeforeInsertAsync(VrstaUslugeInsertRequest request, VrstaUsluge entity, CancellationToken cancellationToken = default)
        {

            await _validator.ValidateInsertAsync(request, cancellationToken);

            entity.IsDeleted = false;

            await base.BeforeInsertAsync(request, entity, cancellationToken);
        }

        public override async Task BeforeUpdateAsync(VrstaUslugeUpdateRequest request, VrstaUsluge entity, CancellationToken cancellationToken = default)
        {
            await _validator.ValidateEntityExistsAsync(entity.VrstaId, cancellationToken);
            await _validator.ValidateUpdateAsync(entity.VrstaId, request, cancellationToken);

            await base.BeforeUpdateAsync(request, entity, cancellationToken);
        }

        public override async Task BeforeDeleteAsync(VrstaUsluge entity, CancellationToken cancellationToken)
        {

            bool uUpotrebi = await Context.Uslugas
                .AnyAsync(x => x.VrstaId == entity.VrstaId && !x.IsDeleted, cancellationToken);

            if (uUpotrebi)
            {
                throw new UserException("Ova vrsta usluge je u upotrebi i ne može biti obrisana.");
            }

            await base.BeforeDeleteAsync(entity, cancellationToken);
        }

       
    }
}
