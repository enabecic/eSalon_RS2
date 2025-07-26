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
    public class RecenzijaOdgovorService : BaseCRUDServiceAsync<Model.RecenzijaOdgovor, RecenzijaOdgovorSearchObject, Database.RecenzijaOdgovor, RecenzijaOdgovorInsertRequest, RecenzijaOdgovorUpdateRequest>, IRecenzijaOdgovorService
    {
        private readonly IKorisnikValidator _korisnikValidator;
        private readonly IRecenzijaValidator _recenzijaValidator;

        public RecenzijaOdgovorService(ESalonContext context, IMapper mapper, IKorisnikValidator korisnikValidator,
            IRecenzijaValidator recenzijaValidator) : base(context, mapper)
        {
            _korisnikValidator = korisnikValidator;
            _recenzijaValidator = recenzijaValidator;
        }

        public override IQueryable<RecenzijaOdgovor> AddFilter(RecenzijaOdgovorSearchObject search, IQueryable<RecenzijaOdgovor> query)
        {
            query = base.AddFilter(search, query);

            if (search.KorisnikId != null)
            {
                query = query.Where(x => x.KorisnikId == search.KorisnikId);
            }

            if (search.RecenzijaId != null)
            {
                query = query.Where(x => x.RecenzijaId == search.RecenzijaId);
            }

            if (search.DatumDodavanjaGTE != null)
            {
                query = query.Where(x => x.DatumDodavanja >= search.DatumDodavanjaGTE);
            }

            if (search.DatumDodavanjaLTE != null)
            {
                query = query.Where(x => x.DatumDodavanja <= search.DatumDodavanjaLTE);
            }

            if (search.BrojLajkovaGTE != null)
            {
                query = query.Where(x => x.BrojLajkova >= search.BrojLajkovaGTE);
            }

            if (search.BrojLajkovaLTE != null)
            {
                query = query.Where(x => x.BrojLajkova <= search.BrojLajkovaLTE);
            }

            if (search.BrojDislajkovaGTE != null)
            {
                query = query.Where(x => x.BrojDislajkova >= search.BrojDislajkovaGTE);
            }

            if (search.BrojDislajkovaLTE != null)
            {
                query = query.Where(x => x.BrojDislajkova <= search.BrojDislajkovaLTE);
            }

            if (!string.IsNullOrWhiteSpace(search.KorisnickoIme))
            {
                var korisnickoImeLower = search.KorisnickoIme.ToLower();
                query = query
                    .Include(x => x.Korisnik)
                    .Where(x => x.Korisnik.KorisnickoIme.ToLower().Contains(korisnickoImeLower));
            }

            if (search.IsDeleted != null)
            {
                query = query.Where(x => x.BrojDislajkova <= search.BrojDislajkovaLTE);
            }

            return query;
        }


        public override async Task<Model.PagedResult<Model.RecenzijaOdgovor>> GetPagedAsync(RecenzijaOdgovorSearchObject search, CancellationToken cancellationToken = default)
        {
            var query = Context.RecenzijaOdgovors.Include(o => o.Korisnik).Include(o => o.Recenzija).Where(o => !o.IsDeleted);

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
            var result = Mapper.Map<List<Model.RecenzijaOdgovor>>(list);

            for (int i = 0; i < result.Count; i++)
            {
                var korisnik = list[i].Korisnik;
                if (korisnik is null) continue;

                result[i].KorisnickoIme = korisnik.KorisnickoIme;

                var recenzija = list[i].Recenzija;
                if (recenzija is not null)
                    result[i].KomentarRecenzije = recenzija.Komentar; 
            }

            return new Model.PagedResult<Model.RecenzijaOdgovor>
            {
                ResultList = result,
                Count = count
            };
        }
   
        public override async Task<Model.RecenzijaOdgovor> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var recenzija = await Context.RecenzijaOdgovors.Include(o => o.Korisnik).Include(o => o.Recenzija)
                .FirstOrDefaultAsync(o => o.RecenzijaOdgovorId == id && !o.IsDeleted && o.Recenzija != null && !o.Recenzija.IsDeleted, cancellationToken);

            if (recenzija == null)
                throw new UserException("Uneseni ID ne postoji.");

            var dto = Mapper.Map<Model.RecenzijaOdgovor>(recenzija);

            dto.KorisnickoIme = $"{recenzija.Korisnik.KorisnickoIme}";
            dto.KomentarRecenzije = recenzija.Recenzija.Komentar;

            return dto;
        }

        public override async Task BeforeInsertAsync(RecenzijaOdgovorInsertRequest request, RecenzijaOdgovor entity, CancellationToken cancellationToken = default)
        {
            await _korisnikValidator.ValidateEntityExistsAsync(request.KorisnikId, cancellationToken);
            await _recenzijaValidator.ValidateEntityExistsAsync(request.RecenzijaId, cancellationToken);

            entity.BrojLajkova = 0;
            entity.BrojDislajkova = 0;
            entity.IsDeleted = false;

            await base.BeforeInsertAsync(request, entity, cancellationToken);
        }

        public async Task ToggleDislikeAsync(int recenzijaOdgovorId, int korisnikId, CancellationToken cancellationToken = default)
        {
            var odgovor = await Context.RecenzijaOdgovors
                 .FirstOrDefaultAsync(x => x.RecenzijaOdgovorId == recenzijaOdgovorId && !x.IsDeleted, cancellationToken);

            if (odgovor == null)
                throw new UserException("Odgovor na recenziju ne postoji.");

            var reakcija = await Context.RecenzijaOdgovorReakcijas
                .FirstOrDefaultAsync(x => x.RecenzijaOdgovorId == recenzijaOdgovorId &&
                                           x.KorisnikId == korisnikId &&
                                           !x.IsDeleted, cancellationToken);

            if (reakcija == null)
            {
                await Context.RecenzijaOdgovorReakcijas.AddAsync(new RecenzijaOdgovorReakcija
                {
                    RecenzijaOdgovorId = recenzijaOdgovorId,
                    KorisnikId = korisnikId,
                    DatumReakcije=DateTime.Now,
                    JeLajk = false,
                    IsDeleted = false
                }, cancellationToken);

                odgovor.BrojDislajkova++;
            }
            else if (!reakcija.JeLajk)
            {
                reakcija.IsDeleted = true;
                reakcija.VrijemeBrisanja = DateTime.Now;
                odgovor.BrojDislajkova--;
            }
            else
            {
                reakcija.JeLajk = false;
                reakcija.DatumReakcije = DateTime.Now;
                odgovor.BrojDislajkova++;
                odgovor.BrojLajkova--;
            }

            if (odgovor.BrojLajkova < 0 || odgovor.BrojDislajkova < 0)
                throw new UserException("Broj lajkova ili dislajkova ne može biti negativan.");

            await Context.SaveChangesAsync(cancellationToken);
        }

        public async Task ToggleLikeAsync(int recenzijaOdgovorId, int korisnikId, CancellationToken cancellationToken = default)
        {
            var odgovor = await Context.RecenzijaOdgovors
               .FirstOrDefaultAsync(x => x.RecenzijaOdgovorId == recenzijaOdgovorId && !x.IsDeleted, cancellationToken);

            if (odgovor == null)
                throw new UserException("Odgovor na recenziju ne postoji.");

            var reakcija = await Context.RecenzijaOdgovorReakcijas
                .FirstOrDefaultAsync(x => x.RecenzijaOdgovorId == recenzijaOdgovorId &&
                                           x.KorisnikId == korisnikId &&
                                           !x.IsDeleted, cancellationToken);

            if (reakcija == null)
            {
                await Context.RecenzijaOdgovorReakcijas.AddAsync(new RecenzijaOdgovorReakcija
                {
                    RecenzijaOdgovorId = recenzijaOdgovorId,
                    KorisnikId = korisnikId,
                    DatumReakcije=DateTime.Now,
                    JeLajk = true,
                    IsDeleted = false
                }, cancellationToken);

                odgovor.BrojLajkova++;
            }
            else if (reakcija.JeLajk)
            {
                reakcija.IsDeleted = true;
                reakcija.VrijemeBrisanja = DateTime.Now;
                odgovor.BrojLajkova--;
            }
            else
            {
                reakcija.JeLajk = true;
                reakcija.DatumReakcije = DateTime.Now;
                odgovor.BrojLajkova++;
                odgovor.BrojDislajkova--;
            }

            if (odgovor.BrojLajkova < 0 || odgovor.BrojDislajkova < 0)
                throw new UserException("Broj lajkova ili dislajkova ne može biti negativan.");

            await Context.SaveChangesAsync(cancellationToken);
        }
    }
}
