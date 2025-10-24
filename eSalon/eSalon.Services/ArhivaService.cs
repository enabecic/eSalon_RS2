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
    public class ArhivaService : BaseCRUDServiceAsync<Model.Arhiva, ArhivaSearchObject, Database.Arhiva, ArhivaInsertRequest, ArhivaUpdateRequest>, IArhivaService
    {
        private readonly IKorisnikValidator _korisnikValidator;
        private readonly IUslugaValidator _uslugaValidator;
        public ArhivaService(ESalonContext context, IMapper mapper, IKorisnikValidator korisnikValidator,
            IUslugaValidator uslugaValidator) : base(context, mapper)
        {
            _korisnikValidator = korisnikValidator;
            _uslugaValidator = uslugaValidator;
        }

        public override IQueryable<Arhiva> AddFilter(ArhivaSearchObject search, IQueryable<Arhiva> query)
        {
            query = base.AddFilter(search, query);

            if (search.KorisnikId != null)
            {
                query = query.Where(x => x.KorisnikId == search.KorisnikId);
            }

            if (search.UslugaId != null)
            {
                query = query.Where(x => x.UslugaId == search.UslugaId);
            }

            if (search.DatumDodavanjaGTE != null)
            {
                query = query.Where(x => x.DatumDodavanja >= search.DatumDodavanjaGTE);
            }

            if (search.DatumDodavanjaLTE != null)
            {
                query = query.Where(x => x.DatumDodavanja <= search.DatumDodavanjaLTE);
            }

            return query;
        }

        public override async Task<Model.PagedResult<Model.Arhiva>> GetPagedAsync(ArhivaSearchObject search, CancellationToken cancellationToken = default)
        {
            var query = Context.Arhivas
               .Include(a => a.Usluga)
               .Where(a => !a.IsDeleted && a.Usluga != null && !a.Usluga.IsDeleted);


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

            var result = new List<Model.Arhiva>();
            result = Mapper.Map(list, result);

            for (int i = 0; i < result.Count; i++)
            {
                var usluga = list[i].Usluga;
                if (usluga is null) continue;

                result[i].UslugaNaziv = usluga.Naziv;
                result[i].Cijena = usluga.Cijena;
                result[i].Slika = usluga.Slika;
                result[i].Trajanje = usluga.Trajanje;
            }

            return new Model.PagedResult<Model.Arhiva>
            {
                ResultList = result,
                Count = count
            };
        }

        public override async Task BeforeInsertAsync(ArhivaInsertRequest request, Arhiva entity, CancellationToken cancellationToken = default)
        {
            var postoji = await Context.Arhivas
                .AnyAsync(x => x.KorisnikId == request.KorisnikId && x.UslugaId == request.UslugaId && !x.IsDeleted, cancellationToken);

            if (postoji)
            {
                throw new UserException("Ova usluga je već arhivirana.");
            }

            await _korisnikValidator.ValidateEntityExistsAsync(request.KorisnikId, cancellationToken);

            await _uslugaValidator.ValidateEntityExistsAsync(request.UslugaId, cancellationToken);

            entity.IsDeleted = false;
            entity.DatumDodavanja = DateTime.Now;

            await base.BeforeInsertAsync(request, entity, cancellationToken);
        }

        public async Task<int> GetBrojArhiviranjaAsync(int uslugaId, CancellationToken cancellationToken = default)
        {
            return await Context.Arhivas
                 .Where(a => a.UslugaId == uslugaId && !a.IsDeleted)
                 .CountAsync(cancellationToken);
        }
    }
}
