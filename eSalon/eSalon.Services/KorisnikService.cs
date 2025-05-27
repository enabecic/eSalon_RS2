using eSalon.Model.Exceptions;
using eSalon.Model.Requests;
using eSalon.Model.SearchObjects;
using eSalon.Services.Auth;
using eSalon.Services.BaseServicesImplementation;
using eSalon.Services.Database;
using eSalon.Services.Validator.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services
{
    public class KorisnikService : BaseCRUDServiceAsync<Model.Korisnik, KorisnikSearchObject, Database.Korisnik, KorisnikInsertRequest, KorisnikUpdateRequest>, IKorisnikService
    {
        private readonly IUlogaValidator _ulogaValidator;
        private readonly IKorisnikValidator _korisnikValidator;
        private readonly ILogger<KorisnikService> _logger;
        private readonly IPasswordService _passwordService;
        public KorisnikService(ESalonContext context, IMapper mapper, IUlogaValidator ulogaValidator, IKorisnikValidator korisnikValidator,
            ILogger<KorisnikService> logger, IPasswordService passwordService) : base(context, mapper)
        {
            _ulogaValidator = ulogaValidator;
            _korisnikValidator = korisnikValidator;
            _logger = logger;
            _passwordService = passwordService;
        }

        public override IQueryable<Korisnik> AddFilter(KorisnikSearchObject search, IQueryable<Korisnik> query)
        {
            query = base.AddFilter(search, query);


            if (!string.IsNullOrWhiteSpace(search.ImePrezime))
            {
                var imePrezime = search.ImePrezime.ToLower();

                query = query.Where(k =>
                    (k.Ime + " " + k.Prezime).ToLower().Contains(imePrezime) ||
                    k.Ime.ToLower().Contains(imePrezime) ||
                    k.Prezime.ToLower().Contains(imePrezime));
            }


            if (!string.IsNullOrWhiteSpace(search.Email))
                query = query.Where(k => k.Email.ToLower().Contains(search.Email.ToLower()));

            if (!string.IsNullOrWhiteSpace(search.KorisnickoIme))
                query = query.Where(k =>
                    k.KorisnickoIme.ToLower().Contains(search.KorisnickoIme.ToLower()));

            if (!string.IsNullOrWhiteSpace(search.Telefon))
                query = query.Where(k => k.Telefon != null &&
                                         k.Telefon.Contains(search.Telefon));

            if (search?.IsDeleted != null)
            {
                query = query.Where(x => x.IsDeleted == search.IsDeleted);
            }

            if (search.JeAktivan.HasValue)
                query = query.Where(k => k.JeAktivan == search.JeAktivan);


            if (search.UlogaId.HasValue)
            {
                query = query.Where(k => k.KorisniciUloges.Any(ku => ku.UlogaId == search.UlogaId))
                             .Include(k => k.KorisniciUloges)
                             .ThenInclude(ku => ku.Uloga);
            }

            return query;
        }

        public override async Task<Model.Korisnik> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var korisnik = await Context.Korisniks
                .Include(k => k.KorisniciUloges)
                    .ThenInclude(ku => ku.Uloga)
                .FirstOrDefaultAsync(k => k.KorisnikId == id && !k.IsDeleted, cancellationToken);

            if (korisnik == null)
                throw new UserException("Uneseni ID ne postoji.");

            var dto = Mapper.Map<Model.Korisnik>(korisnik);

            dto.Uloge = korisnik.KorisniciUloges
                .Where(ku => !ku.IsDeleted && !ku.Uloga.IsDeleted)
                .Select(ku => ku.Uloga.Naziv)
                .Distinct()
                .ToList();

            return dto;
        }

        public override async Task BeforeInsertAsync(KorisnikInsertRequest request, Korisnik entity, CancellationToken cancellationToken = default)
        {
            await _korisnikValidator.ValidateInsertAsync(request, cancellationToken);

            _ulogaValidator.ValidateNoDuplicates(request.Uloge);
            foreach (int ulogaId in request.Uloge)
                await _ulogaValidator.ValidateEntityExistsAsync(ulogaId, cancellationToken);

            entity.LozinkaSalt = _passwordService.GenerateSalt();
            entity.LozinkaHash = _passwordService.GenerateHash(entity.LozinkaSalt, request.Lozinka);


            entity.DatumRegistracije = DateTime.Now;
            entity.JeAktivan = true;
            entity.IsDeleted = false;

            _logger.LogInformation("Dodavanje korisnika sa korisničkim imenom: {KorisnickoIme}", entity.KorisnickoIme);


            await base.BeforeInsertAsync(request, entity, cancellationToken);
        }

        public override async Task AfterInsertAsync(KorisnikInsertRequest request, Korisnik entity, CancellationToken cancellationToken = default)
        {
            if (request.Uloge?.Any() == true)
            {
                var korisnikUloge = request.Uloge.Select(ulogaId => new Database.KorisniciUloge
                {
                    KorisnikId = entity.KorisnikId,
                    UlogaId = ulogaId,
                    IsDeleted = false
                }).ToList();


                Context.KorisniciUloges.AddRange(korisnikUloge);
                await Context.SaveChangesAsync(cancellationToken);
            }

            await base.AfterInsertAsync(request, entity, cancellationToken);
        }

        public override async Task BeforeUpdateAsync(KorisnikUpdateRequest request, Korisnik entity, CancellationToken cancellationToken = default)
        {
            await base.BeforeUpdateAsync(request, entity, cancellationToken);

            await _korisnikValidator.ValidateUpdateAsync(entity.KorisnikId, request, cancellationToken);

            bool zeliPromijenitiLozinku =
                !string.IsNullOrWhiteSpace(request.StaraLozinka) ||
                !string.IsNullOrWhiteSpace(request.Lozinka) ||
                !string.IsNullOrWhiteSpace(request.LozinkaPotvrda);

            if (zeliPromijenitiLozinku)
            {
                if (string.IsNullOrWhiteSpace(request.StaraLozinka))
                    throw new UserException("Morate unijeti staru lozinku.");

                if (string.IsNullOrWhiteSpace(request.Lozinka) || string.IsNullOrWhiteSpace(request.LozinkaPotvrda))
                    throw new UserException("Morate unijeti novu lozinku i njenu potvrdu.");

                if (request.Lozinka != request.LozinkaPotvrda)
                    throw new UserException("Nova lozinka i potvrda lozinke se ne podudaraju.");

                var stariHash = _passwordService.GenerateHash(entity.LozinkaSalt, request.StaraLozinka);
                if (stariHash != entity.LozinkaHash)
                    throw new UserException("Unesena stara lozinka nije tačna.");


                entity.LozinkaSalt = _passwordService.GenerateSalt();
                entity.LozinkaHash = _passwordService.GenerateHash(entity.LozinkaSalt, request.Lozinka);

                _logger.LogInformation("Korisnik {Username} je uspješno promijenio lozinku.", entity.KorisnickoIme);

            }
        }

        public async Task<Model.Korisnik> LoginAsync(KorisnikLoginRequest request, CancellationToken cancellationToken = default)
        {
            var entity = await Context.Korisniks
              .Include(k => k.KorisniciUloges)
              .ThenInclude(ku => ku.Uloga)
               .FirstOrDefaultAsync(k => k.KorisnickoIme == request.KorisnickoIme,
            cancellationToken);

            if (entity == null)
            {
                _logger.LogWarning("Pokušaj prijave s nepostojećim korisničkim imenom: {Username}",
                                   request.KorisnickoIme);
                throw new UserException("Neispravno korisničko ime ili lozinka.");
            }

            var hash = _passwordService.GenerateHash(entity.LozinkaSalt, request.Lozinka);

            if (hash != entity.LozinkaHash)
            {
                _logger.LogWarning("Neuspješna prijava za korisnika {Username} – pogrešna lozinka.",
                                   request.KorisnickoIme);
                throw new UserException("Neispravno korisničko ime ili lozinka.");
            }

            _logger.LogInformation("Uspješna prijava za korisnika {Username}", request.KorisnickoIme);

            var dto = Mapper.Map<Model.Korisnik>(entity);

            dto.Uloge = entity.KorisniciUloges
                .Where(ku => !ku.IsDeleted && !ku.Uloga.IsDeleted)
                .Select(ku => ku.Uloga.Naziv)
                .Distinct()
                .ToList();

            return dto;
        }
    }
}
