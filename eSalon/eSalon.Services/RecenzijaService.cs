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
    public class RecenzijaService : BaseCRUDServiceAsync<Model.Recenzija, RecenzijaSearchObject, Database.Recenzija, RecenzijaInsertRequest, RecenzijaUpdateRequest>, IRecenzijaService
    {
        private readonly IKorisnikValidator _korisnikValidator;
        private readonly IUslugaValidator _uslugaValidator;
        private readonly IRecenzijaOdgovorService _recenzijaOdgovorService;

        public RecenzijaService(ESalonContext context, IMapper mapper, IKorisnikValidator korisnikValidator,
            IUslugaValidator uslugaValidator, IRecenzijaOdgovorService recenzijaOdgovorService
            ) : base(context, mapper)
        {
            _korisnikValidator = korisnikValidator;
            _uslugaValidator = uslugaValidator;
            _recenzijaOdgovorService = recenzijaOdgovorService;
        }

        public override IQueryable<Recenzija> AddFilter(RecenzijaSearchObject search, IQueryable<Recenzija> query)
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

            if (search?.IsDeleted != null)
            {
                query = query.Where(x => x.IsDeleted == search.IsDeleted);
            }

            return query;
        }

        public override async Task<Model.PagedResult<Model.Recenzija>> GetPagedAsync(RecenzijaSearchObject search, CancellationToken cancellationToken = default)
        {
            var query = Context.Recenzijas.Include(r => r.Korisnik).Include(r => r.Usluga).Where(r => !r.IsDeleted);

            query = AddFilter(search, query);

            int count = await query.CountAsync(cancellationToken);

            if (!string.IsNullOrEmpty(search?.OrderBy) && !string.IsNullOrEmpty(search?.SortDirection))
            {
                query = ApplySorting(query, search.OrderBy, search.SortDirection);
            }

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync(cancellationToken);

            var result = Mapper.Map<List<Model.Recenzija>>(list);

            for (int i = 0; i < result.Count; i++)
            {
                var korisnik = list[i].Korisnik;
                if (korisnik is null) continue;

                result[i].KorisnickoIme = korisnik.KorisnickoIme;

                var usluga = list[i].Usluga;
                if (usluga is null) continue;

                result[i].NazivUsluge = usluga.Naziv;

            }

            return new Model.PagedResult<Model.Recenzija>
            {
                ResultList = result,
                Count = count
            };
        }

        public override async Task<Model.Recenzija> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var recenzija = await Context.Recenzijas
          .Include(r => r.Korisnik)
          .Include(r => r.Usluga)
          .FirstOrDefaultAsync(r => r.RecenzijaId == id && !r.IsDeleted, cancellationToken);

            if (recenzija == null)
                throw new UserException("Uneseni ID ne postoji.");

            var dto = Mapper.Map<Model.Recenzija>(recenzija);

            dto.KorisnickoIme = recenzija.Korisnik?.KorisnickoIme;
            dto.NazivUsluge = recenzija.Usluga?.Naziv;

            return dto;
        }


        public override async Task BeforeInsertAsync(RecenzijaInsertRequest request, Recenzija entity, CancellationToken cancellationToken = default)
        {
            var postojiRecenzija = await Context.Recenzijas
                 .AnyAsync(x => x.KorisnikId == request.KorisnikId && x.UslugaId == request.UslugaId
                 && !x.IsDeleted, cancellationToken);

            if (postojiRecenzija)
            {
                throw new UserException("Već ste ostavili recenziju za ovu uslugu.");
            }

            var imaRezervaciju = await Context.Rezervacijas
             .Where(r => r.KorisnikId == request.KorisnikId && !r.IsDeleted && r.StateMachine == "zavrsena")
              .AnyAsync(r => r.StavkeRezervacijes.Any(sr => sr.UslugaId == request.UslugaId), cancellationToken);

            if (!imaRezervaciju)
            {
                throw new UserException("Možete ostaviti recenziju samo za usluge koje ste prethodno rezervisali i koje su Vam pružene.");
            }

            await _korisnikValidator.ValidateEntityExistsAsync(request.KorisnikId, cancellationToken);
            await _uslugaValidator.ValidateEntityExistsAsync(request.UslugaId, cancellationToken);

            entity.BrojLajkova = 0;
            entity.BrojDislajkova = 0;
            entity.IsDeleted = false;

            await base.BeforeInsertAsync(request, entity, cancellationToken);
        }

        public async Task ToggleDislikeAsync(int recenzijaId, int korisnikId, CancellationToken cancellationToken = default)
        {
            var recenzija = await Context.Recenzijas
                .FirstOrDefaultAsync(x => x.RecenzijaId == recenzijaId && !x.IsDeleted, cancellationToken);

            if (recenzija == null)
                throw new UserException("Recenzija ne postoji.");

            var reakcija = await Context.RecenzijaReakcijas
                .FirstOrDefaultAsync(x => x.RecenzijaId == recenzijaId && x.KorisnikId == korisnikId && !x.IsDeleted, cancellationToken);

            if (reakcija == null)
            {
                await Context.RecenzijaReakcijas.AddAsync(new RecenzijaReakcija
                {
                    RecenzijaId = recenzijaId,
                    KorisnikId = korisnikId,
                    DatumReakcije = DateTime.Now,
                    JeLajk = false,
                    IsDeleted = false
                }, cancellationToken);

                recenzija.BrojDislajkova++;
            }
            else if (!reakcija.JeLajk)
            {
                reakcija.IsDeleted = true;
                reakcija.VrijemeBrisanja = DateTime.Now;
                recenzija.BrojDislajkova--;
            }
            else
            {
                reakcija.JeLajk = false;
                reakcija.DatumReakcije = DateTime.Now;
                recenzija.BrojDislajkova++;
                recenzija.BrojLajkova--;
            }

            if (recenzija.BrojLajkova < 0 || recenzija.BrojDislajkova < 0)
            {
                throw new UserException("Broj lajkova ili dislajkova ne može biti negativan.");
            }


            await Context.SaveChangesAsync(cancellationToken);
        }

        public async Task ToggleLikeAsync(int recenzijaId, int korisnikId, CancellationToken cancellationToken = default)
        {
            var recenzija = await Context.Recenzijas
                .FirstOrDefaultAsync(x => x.RecenzijaId == recenzijaId && !x.IsDeleted, cancellationToken);

            if (recenzija == null)
                throw new UserException("Recenzija ne postoji.");

            var reakcija = await Context.RecenzijaReakcijas
                .FirstOrDefaultAsync(x => x.RecenzijaId == recenzijaId && x.KorisnikId == korisnikId && !x.IsDeleted, cancellationToken);

            if (reakcija == null)
            {
                await Context.RecenzijaReakcijas.AddAsync(new RecenzijaReakcija
                {
                    RecenzijaId = recenzijaId,
                    KorisnikId = korisnikId,
                    DatumReakcije = DateTime.Now,
                    JeLajk = true,
                    IsDeleted = false
                }, cancellationToken);

                recenzija.BrojLajkova++;
            }
            else if (reakcija.JeLajk)
            {
                reakcija.IsDeleted = true;
                reakcija.VrijemeBrisanja = DateTime.Now;
                recenzija.BrojLajkova--;
            }
            else
            {
                reakcija.JeLajk = true;
                reakcija.DatumReakcije = DateTime.Now;
                recenzija.BrojLajkova++;
                recenzija.BrojDislajkova--;
            }

            if (recenzija.BrojLajkova < 0 || recenzija.BrojDislajkova < 0)
            {
                throw new UserException("Broj lajkova ili dislajkova ne može biti negativan.");
            }

            await Context.SaveChangesAsync(cancellationToken);
        }

        public override async Task BeforeDeleteAsync(Recenzija entity, CancellationToken cancellationToken)
        {
            var odgovori = await Context.RecenzijaOdgovors
                 .Where(x => x.RecenzijaId == entity.RecenzijaId)
                 .ToListAsync(cancellationToken);

            foreach (var odgovor in odgovori)
            {
                await _recenzijaOdgovorService.DeleteAsync(odgovor.RecenzijaOdgovorId, cancellationToken);
            }

            await base.BeforeDeleteAsync(entity, cancellationToken);
        }
    }
}
