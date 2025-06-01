using eSalon.Model.Exceptions;
using eSalon.Model.Requests;
using eSalon.Model.SearchObjects;
using eSalon.Services.BaseServicesImplementation;
using eSalon.Services.Database;
using eSalon.Services.Helpers;
using eSalon.Services.Validator.Implementation;
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
    public class PromocijaService : BaseCRUDServiceAsync<Model.Promocija, PromocijaSearchObject, Database.Promocija, PromocijaInsertRequest, PromocijaUpdateRequest>, IPromocijaService
    {
        private readonly IUslugaValidator _uslugaValidator;
        private readonly IPromocijaValidator _promocijaValidator;
        private readonly ICodeGenerator _codeGenerator;

        public PromocijaService(ESalonContext context, IMapper mapper, IUslugaValidator uslugaValidator , IPromocijaValidator promocijaValidator,ICodeGenerator codeGenerator
            ) : base(context, mapper)
        {
            _uslugaValidator = uslugaValidator;
            _promocijaValidator = promocijaValidator;
            _codeGenerator = codeGenerator;
        }

        public override IQueryable<Promocija> AddFilter(PromocijaSearchObject search, IQueryable<Promocija> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.NazivOpisFTS))
            {
                var pattern = $"%{search.NazivOpisFTS}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Naziv, pattern) ||
                    EF.Functions.Like(x.Opis, pattern)
                );
            }

            if (search.PopustGTE != null)
            {
                query = query.Where(x => x.Popust >= search.PopustGTE);
            }

            if (search.PopustLTE != null)
            {
                query = query.Where(x => x.Popust <= search.PopustLTE);
            }

            if (search.UslugaId != null)
            {
                query = query.Where(x => x.UslugaId == search.UslugaId);
            }

            if (search?.IsDeleted != null)
            {
                query = query.Where(x => x.IsDeleted == search.IsDeleted);
            }

            if (search.SamoAktivne == true)
            {
                var danas = DateTime.Now;
                query = query.Where(x => x.DatumPocetka <= danas && x.DatumKraja >= danas);
            }

            if (search.SamoBuduce == true)
            {
                var danas = DateTime.Now;
                query = query.Where(x => x.DatumPocetka > danas);
            }

            if (search.SamoProsle == true)
            {
                var danas = DateTime.Now;
                query = query.Where(x => x.DatumKraja < danas);
            }

            return query;
        }

        public override async Task<Model.Promocija> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var promocija = await Context.Promocijas
                .Include(k => k.Usluga)
                .FirstOrDefaultAsync(k => k.PromocijaId == id && !k.IsDeleted, cancellationToken);

            if (promocija == null)
                throw new UserException("Uneseni ID ne postoji.");

            var dto = Mapper.Map<Model.Promocija>(promocija);

            dto.UslugaNaziv = $"{promocija.Usluga.Naziv}";
            dto.SlikaUsluge = promocija.Usluga.Slika;

            return dto;
        }

        public override async Task<Model.PagedResult<Model.Promocija>> GetPagedAsync(PromocijaSearchObject search, CancellationToken cancellationToken = default)
        {
            var query = Context.Promocijas
              .Include(f => f.Usluga)
              .Where(f => !f.IsDeleted);

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

            var result = Mapper.Map<List<Model.Promocija>>(list);

            for (int i = 0; i < result.Count; i++)
            {
                var usluga = list[i].Usluga;
                if (usluga == null) continue;

                result[i].UslugaNaziv = usluga.Naziv;
                result[i].SlikaUsluge = usluga.Slika;
            }

            return new Model.PagedResult<Model.Promocija>
            {
                ResultList = result,
                Count = count
            };
        }

        public override async Task BeforeInsertAsync(PromocijaInsertRequest request, Promocija entity, CancellationToken cancellationToken = default)
        {
            await _promocijaValidator.ValidateInsertAsync(request, cancellationToken);

            await _uslugaValidator.ValidateEntityExistsAsync(request.UslugaId, cancellationToken);

            entity.IsDeleted = false;

            entity.Status = true;

            entity.Kod = await _codeGenerator.GenerateUniqueCodeAsync(
               async kod => await Context.Promocijas.AnyAsync(p => p.Kod == kod) );


            await base.BeforeInsertAsync(request, entity, cancellationToken);
        }

        public override async Task BeforeUpdateAsync(PromocijaUpdateRequest request, Promocija entity, CancellationToken cancellationToken = default)
        {
            await _promocijaValidator.ValidateUpdateAsync(entity.PromocijaId, request, cancellationToken);

            await _uslugaValidator.ValidateEntityExistsAsync(request.UslugaId, cancellationToken);

            await base.BeforeUpdateAsync(request, entity, cancellationToken);
        }

        public override async Task BeforeDeleteAsync(Promocija entity, CancellationToken cancellationToken)
        {
            bool uUpotrebi =
               await Context.AktiviranaPromocijas.AnyAsync(x => x.PromocijaId == entity.PromocijaId && !x.IsDeleted, cancellationToken);

            if (uUpotrebi)
            {
                throw new UserException("Promocija je u upotrebi i ne može biti obrisana.");
            }

            if (entity.DatumKraja > DateTime.Now)
            {
                throw new UserException("Promociju nije moguće obrisati jer još uvijek nije istekla.");
            }

            await base.BeforeDeleteAsync(entity, cancellationToken);
        }


    }
}
