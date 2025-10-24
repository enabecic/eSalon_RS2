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
    public class FavoritService : BaseCRUDServiceAsync<Model.Favorit, FavoritSearchObject, Database.Favorit, FavoritInsertRequest, FavoritUpdateRequest>, IFavoritService
    {
        private readonly IKorisnikValidator _korisnikValidator;
        private readonly IUslugaValidator _uslugaValidator;

        public FavoritService(ESalonContext context, IMapper mapper, IKorisnikValidator korisnikValidator, IUslugaValidator uslugaValidator) : base(context, mapper)
        {
            _korisnikValidator = korisnikValidator;
            _uslugaValidator = uslugaValidator;
        }

        public override IQueryable<Favorit> AddFilter(FavoritSearchObject search, IQueryable<Favorit> query)
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

            if (search.IsDeleted != null)
            {
                query = query.Where(x => x.IsDeleted == search.IsDeleted);
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

        public override async Task<Model.Favorit> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var favorit = await Context.Favorits
               .Include(k => k.Usluga)
               .FirstOrDefaultAsync(k => k.FavoritId == id && !k.IsDeleted, cancellationToken);

            if (favorit == null)
                throw new UserException("Uneseni ID ne postoji.");

            var dto = Mapper.Map<Model.Favorit>(favorit);

            dto.UslugaNaziv = $"{favorit.Usluga.Naziv}";
            dto.Cijena = favorit.Usluga.Cijena;
            dto.Slika = favorit.Usluga.Slika;
            dto.Trajanje = favorit.Usluga.Trajanje;

            return dto;
        }


        public override async Task<Model.PagedResult<Model.Favorit>> GetPagedAsync(FavoritSearchObject search, CancellationToken cancellationToken = default)
        {
            var query = Context.Favorits
              .Include(f => f.Usluga)
              .Where(f => !f.IsDeleted && f.Usluga != null && !f.Usluga.IsDeleted);

            query = AddFilter(search, query);

            var count = await query.CountAsync(cancellationToken);

            if (!string.IsNullOrEmpty(search?.OrderBy) &&
                !string.IsNullOrEmpty(search?.SortDirection))
            {
                query = ApplySorting(query, search.OrderBy, search.SortDirection);
            }

            if (search?.Page.HasValue == true && search.PageSize.HasValue)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync(cancellationToken);

            var result = Mapper.Map<List<Model.Favorit>>(list);

            for (int i = 0; i < result.Count; i++)
            {
                var usluga = list[i].Usluga;
                if (usluga == null) continue;

                result[i].UslugaNaziv = usluga.Naziv;
                result[i].Cijena = usluga.Cijena;
                result[i].Slika = usluga.Slika;
                result[i].Trajanje=usluga.Trajanje;
                
            }

            return new Model.PagedResult<Model.Favorit>
            {
                ResultList = result,
                Count = count
            };
        }

        public override async Task BeforeInsertAsync(FavoritInsertRequest request, Favorit entity, CancellationToken cancellationToken = default)
        {         
            var postoji = await Context.Favorits
                .AnyAsync(x => x.KorisnikId == request.KorisnikId
                            && x.UslugaId == request.UslugaId
                            && !x.IsDeleted,
                          cancellationToken);

            if (postoji)
                throw new UserException("Ova usluga je već dodana u favorite.");


            await _korisnikValidator.ValidateEntityExistsAsync(request.KorisnikId, cancellationToken);
            await _uslugaValidator.ValidateEntityExistsAsync(request.UslugaId, cancellationToken);


            entity.IsDeleted = false;
            entity.DatumDodavanja = DateTime.Now;

            await base.BeforeInsertAsync(request, entity, cancellationToken);
        }

     
    }
}
