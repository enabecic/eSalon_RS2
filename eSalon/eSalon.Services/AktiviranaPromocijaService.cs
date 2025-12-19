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
    public class AktiviranaPromocijaService : BaseCRUDServiceAsync<Model.AktiviranaPromocija, AktiviranaPromocijaSearchObject, Database.AktiviranaPromocija, AktiviranaPromocijaInsertRequest, AktiviranaPromocijaUpdateRequest>, IAktiviranaPromocijaService
    {
        private readonly IKorisnikValidator _korisnikValidator;
        private readonly IPromocijaValidator _promocijaValidator;

        public AktiviranaPromocijaService(ESalonContext context, IMapper mapper, IKorisnikValidator korisnikValidator, IPromocijaValidator promocijaValidator) : base(context, mapper)
        {
            _korisnikValidator= korisnikValidator;
            _promocijaValidator= promocijaValidator;
        }

        public override IQueryable<AktiviranaPromocija> AddFilter(AktiviranaPromocijaSearchObject search, IQueryable<AktiviranaPromocija> query)
        {
            query = base.AddFilter(search, query);

            if (search.KorisnikId.HasValue)
                query = query.Where(x => x.KorisnikId == search.KorisnikId.Value);

            if (search.PromocijaId.HasValue)
                query = query.Where(x => x.PromocijaId == search.PromocijaId.Value);

            if (search.Aktivirana.HasValue)
                query = query.Where(x => x.Aktivirana == search.Aktivirana.Value);

            if (search.Iskoristena.HasValue)
                query = query.Where(x => x.Iskoristena == search.Iskoristena.Value);

            if (!string.IsNullOrWhiteSpace(search.KorisnikImePrezime))
            {
                var korisnikImePrezime = search.KorisnikImePrezime.ToLower();

                query = query.Include(x => x.Korisnik)
                             .Where(x =>
                                 (x.Korisnik.Ime + " " + x.Korisnik.Prezime).ToLower().Contains(korisnikImePrezime) ||
                                 x.Korisnik.Ime.ToLower().Contains(korisnikImePrezime) ||
                                 x.Korisnik.Prezime.ToLower().Contains(korisnikImePrezime));
            }

            if (!string.IsNullOrWhiteSpace(search.PromocijaNaziv))
            {
                var promocijaNaziv = search.PromocijaNaziv.ToLower();

                query = query.Include(x => x.Promocija)
                             .Where(x => x.Promocija.Naziv.ToLower().Contains(promocijaNaziv));
            }

            if (search?.IsDeleted != null)
            {
                query = query.Where(x => x.IsDeleted == search.IsDeleted);
            }
            return query;
        }

        public override async Task<Model.AktiviranaPromocija> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var aktiviranapromocija = await Context.AktiviranaPromocijas
              .Include(x => x.Promocija).ThenInclude(u=>u.Usluga)
              .Include(x => x.Korisnik)
              .FirstOrDefaultAsync(x => x.AktiviranaPromocijaId == id && !x.IsDeleted, cancellationToken);

            if (aktiviranapromocija == null)
                throw new UserException("Uneseni ID ne postoji.");

            var dto = Mapper.Map<Model.AktiviranaPromocija>(aktiviranapromocija);

            dto.PromocijaNaziv = aktiviranapromocija.Promocija.Naziv;
            dto.KorisnikImePrezime = $"{aktiviranapromocija.Korisnik.Ime} {aktiviranapromocija.Korisnik.Prezime}";
            dto.KodPromocije = aktiviranapromocija.Promocija.Kod;
            dto.SlikaUsluge = aktiviranapromocija.Promocija.Usluga.Slika;
            dto.Popust = aktiviranapromocija.Promocija.Popust;
            dto.DatumPocetka = aktiviranapromocija.Promocija.DatumPocetka;
            dto.DatumKraja = aktiviranapromocija.Promocija.DatumKraja;

            return dto;
        }


        public override async Task<Model.PagedResult<Model.AktiviranaPromocija>> GetPagedAsync(AktiviranaPromocijaSearchObject search, CancellationToken cancellationToken = default)
        {
            var query = Context.AktiviranaPromocijas
              .Include(a => a.Promocija).ThenInclude(u => u.Usluga)
               .Include(a => a.Korisnik)
              .Where(a => !a.IsDeleted);

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

            var result = Mapper.Map<List<Model.AktiviranaPromocija>>(list);

            for (int i = 0; i < result.Count; i++)
            {
                var promocija = list[i].Promocija;
                if (promocija != null)
                {
                    result[i].PromocijaNaziv = promocija.Naziv;
                    result[i].SlikaUsluge = promocija.Usluga.Slika;
                    result[i].Popust = promocija.Popust;
                   // result[i].KodPromocije = promocija.Kod;
                    result[i].DatumPocetka = promocija.DatumPocetka;
                    result[i].DatumKraja = promocija.DatumKraja;
                }
                var korisnik = list[i].Korisnik;
                if (korisnik != null)
                {
                    result[i].KorisnikImePrezime = $"{korisnik.Ime} {korisnik.Prezime}";
                }
            }

            return new Model.PagedResult<Model.AktiviranaPromocija>
            {
                ResultList = result,
                Count = count
            };
        }

        public override async Task BeforeInsertAsync(AktiviranaPromocijaInsertRequest request, AktiviranaPromocija entity, CancellationToken cancellationToken = default)
        {
          
            bool postoji = await Context.AktiviranaPromocijas.AnyAsync(
            x => x.PromocijaId == request.PromocijaId &&
            x.KorisnikId == request.KorisnikId && !x.IsDeleted, cancellationToken);

            if (postoji)
                throw new UserException($"Korisnik {request.KorisnikId} je već aktivirao promociju {request.PromocijaId}.");

            await _korisnikValidator.ValidateEntityExistsAsync(request.KorisnikId, cancellationToken);

            await _promocijaValidator.ValidateEntityExistsAsync(request.PromocijaId, cancellationToken);

            entity.IsDeleted = false;
            entity.Aktivirana=true;
            entity.Iskoristena = false;
            entity.DatumAktiviranja = DateTime.Now;

            await base.BeforeInsertAsync(request, entity, cancellationToken);
        }

        public override async Task BeforeUpdateAsync(AktiviranaPromocijaUpdateRequest request, AktiviranaPromocija entity, CancellationToken cancellationToken = default)
        {
            entity.Iskoristena = true;

            await base.BeforeUpdateAsync(request, entity, cancellationToken);
        }

        public override async Task BeforeDeleteAsync(AktiviranaPromocija entity, CancellationToken cancellationToken)
        {
            bool uUpotrebi =
             await Context.Rezervacijas.AnyAsync(x => x.AktiviranaPromocijaId == entity.AktiviranaPromocijaId && !x.IsDeleted, cancellationToken);

            if (uUpotrebi)
            {
                throw new UserException("Aktivirana promocija je u upotrebi i ne može biti obrisana.");
            }

            await base.BeforeDeleteAsync(entity, cancellationToken);
        }

    }
}
