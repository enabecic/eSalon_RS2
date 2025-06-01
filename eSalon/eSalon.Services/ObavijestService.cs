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
    public class ObavijestService : BaseCRUDServiceAsync<Model.Obavijest, ObavijestSearchObject, Database.Obavijest, ObavijestInsertRequest, ObavijestUpdateRequest>, IObavijestService
    {
        public ObavijestService(ESalonContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Obavijest> AddFilter(ObavijestSearchObject search, IQueryable<Obavijest> query)
        {
            query = base.AddFilter(search, query);

            if (search.KorisnikId != null)
            {
                query = query.Where(x => x.KorisnikId == search.KorisnikId);
            }

            if (!string.IsNullOrWhiteSpace(search.Naslov))
            {
                query = query.Where(x => x.Naslov.ToLower().Contains(search.Naslov.ToLower()));
            }

            if (search.DatumObavijestiGTE != null)
            {
                query = query.Where(x => x.DatumObavijesti >= search.DatumObavijestiGTE);
            }

            if (search.DatumObavijestiLTE != null)
            {
                query = query.Where(x => x.DatumObavijesti <= search.DatumObavijestiLTE);
            }

            if (search.JePogledana != null)
            {
                query = query.Where(x => x.JePogledana == search.JePogledana);
            }

            return query;
        }

        public override async Task<Model.PagedResult<Model.Obavijest>> GetPagedAsync(ObavijestSearchObject search, CancellationToken cancellationToken = default)
        {
            var query = Context.Obavijests.Include(o => o.Korisnik).Where(o => !o.IsDeleted);

            query = AddFilter(search, query);

            int count = await query.CountAsync(cancellationToken);

            if (!string.IsNullOrEmpty(search?.OrderBy) &&
                !string.IsNullOrEmpty(search?.SortDirection))
            {
                query = ApplySorting(query, search.OrderBy, search.SortDirection);
            }

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query
                    .Skip((search.Page.Value - 1) * search.PageSize.Value)
                    .Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync(cancellationToken);
            var result = Mapper.Map<List<Model.Obavijest>>(list);

            for (int i = 0; i < result.Count; i++)
            {
                var korisnik = list[i].Korisnik;
                if (korisnik is null) continue;

                result[i].ImePrezime = $"{korisnik.Ime} {korisnik.Prezime}";
            }

            return new Model.PagedResult<Model.Obavijest>
            {
                ResultList = result,
                Count = count
            };
        }

        public override async Task<Model.Obavijest> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var obavijest = await Context.Obavijests
                .Include(o => o.Korisnik)
                .FirstOrDefaultAsync(o => o.ObavijestId == id && !o.IsDeleted, cancellationToken);

            if (obavijest == null)
                throw new UserException("Uneseni ID ne postoji.");

            var dto = Mapper.Map<Model.Obavijest>(obavijest);

            if (obavijest.Korisnik != null)
                dto.ImePrezime = $"{obavijest.Korisnik.Ime} {obavijest.Korisnik.Prezime}";

            return dto;
        }

        public override Task BeforeInsertAsync(ObavijestInsertRequest request, Obavijest entity, CancellationToken cancellationToken = default)
        {
            entity.IsDeleted = false;
            entity.JePogledana = false;

            return base.BeforeInsertAsync(request, entity, cancellationToken);
        }

        public async Task OznaciKaoProcitanuAsync(int obavijestId, CancellationToken cancellationToken = default)
        {
            var obavijest = await Context.Obavijests
         .FirstOrDefaultAsync(o => o.ObavijestId == obavijestId && !o.IsDeleted, cancellationToken);

            if (obavijest == null)
                throw new UserException("Obavijest nije pronađena.");

            if (!obavijest.JePogledana)
            {
                obavijest.JePogledana = true;
                await Context.SaveChangesAsync(cancellationToken);
            }
        }
    }
}
