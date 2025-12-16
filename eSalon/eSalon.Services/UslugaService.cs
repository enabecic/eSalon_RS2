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
    public class UslugaService : BaseCRUDServiceAsync<Model.Usluga, UslugaSearchObject, Database.Usluga, UslugaInsertRequest, UslugaUpdateRequest>, IUslugaService
    {
        private readonly IVrstaUslugeValidator _vrstaUslugeValidator;
        private readonly IUslugaValidator _uslugaValidator;
        private readonly IObavijestService _obavijestService;
        public UslugaService(ESalonContext context, IMapper mapper, IVrstaUslugeValidator vrstaUslugeValidator, IUslugaValidator uslugaValidator, IObavijestService obavijestService) : base(context, mapper)
        {
            _vrstaUslugeValidator = vrstaUslugeValidator;
            _uslugaValidator = uslugaValidator;
            _obavijestService = obavijestService;
        }

        public override IQueryable<Usluga> AddFilter(UslugaSearchObject search, IQueryable<Usluga> query)
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

            if (search.TrajanjeGTE != null)
            {
                query = query.Where(x => x.Trajanje >= search.TrajanjeGTE);
            }

            if (search.TrajanjeLTE != null)
            {
                query = query.Where(x => x.Trajanje <= search.TrajanjeLTE);
            }

            if (search.CijenaGTE != null)
            {
                query = query.Where(x => x.Cijena >= search.CijenaGTE);
            }

            if (search.CijenaLTE != null)
            {
                query = query.Where(x => x.Cijena <= search.CijenaLTE);
            }

            if (search.VrstaId != null)
            {
                query = query.Where(x => x.VrstaId == search.VrstaId);
            }

            if (search.BrojZadnjeDodanih.HasValue && search.BrojZadnjeDodanih > 0)
            {
                query = query
                    .OrderByDescending(x => x.DatumObjavljivanja)
                    .Take(search.BrojZadnjeDodanih.Value);
            }

            if (search?.IsDeleted != null)
            {
                query = query.Where(x => x.IsDeleted == search.IsDeleted);
            }
            return query;
        }



        public override async Task<Model.Usluga> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var usluga = await Context.Uslugas
                .Include(k => k.Vrsta)
                .FirstOrDefaultAsync(k => k.UslugaId == id && !k.IsDeleted, cancellationToken);

            if (usluga == null)
                throw new UserException("Uneseni ID ne postoji.");

            var dto = Mapper.Map<Model.Usluga>(usluga);

            dto.VrstaUslugeNaziv = $"{usluga.Vrsta.Naziv}";

            return dto;
        }


        public override async Task BeforeInsertAsync(UslugaInsertRequest request, Usluga entity, CancellationToken cancellationToken = default)
        {
            await _uslugaValidator.ValidateInsertAsync(request,cancellationToken);

            await _vrstaUslugeValidator.ValidateEntityExistsAsync(request.VrstaId,cancellationToken);

            entity.IsDeleted = false;

            entity.DatumObjavljivanja=DateTime.Now;

            await base.BeforeInsertAsync(request, entity, cancellationToken);
        }

        public override async Task BeforeUpdateAsync(UslugaUpdateRequest request, Usluga entity, CancellationToken cancellationToken = default)
        {
            await _uslugaValidator.ValidateUpdateAsync(entity.UslugaId,request,cancellationToken);

            await _vrstaUslugeValidator.ValidateEntityExistsAsync(request.VrstaId, cancellationToken);

            await base.BeforeUpdateAsync(request, entity, cancellationToken);
        }

        public override async Task BeforeDeleteAsync(Usluga entity, CancellationToken cancellationToken)
        {
            bool uUpotrebi = await Context.Promocijas.AnyAsync(x => x.UslugaId == entity.UslugaId && !x.IsDeleted &&
             x.DatumPocetka.Date <= DateTime.Now.Date && x.DatumKraja.Date >= DateTime.Now.Date, cancellationToken);

            if (uUpotrebi)
            {
                throw new UserException("Usluga je trenutno u aktivnoj promociji i ne može biti obrisana dok promocija ne istekne.");
            }

            await base.BeforeDeleteAsync(entity, cancellationToken);

        }

        public override async Task AfterInsertAsync(UslugaInsertRequest request, Usluga entity, CancellationToken cancellationToken = default)
        {
            await base.AfterInsertAsync(request, entity, cancellationToken);

            var klijenti = await Context.Korisniks
                .Where(k => !k.IsDeleted && k.KorisniciUloges.Any(u => u.Uloga.Naziv == "Klijent"))
                .ToListAsync(cancellationToken);

            foreach (var klijent in klijenti)
            {
                var obavijest = new ObavijestInsertRequest
                {
                    KorisnikId = klijent.KorisnikId,
                    Naslov = "Nova usluga u eSalonu",
                    Sadrzaj = $"Pozdrav {klijent.Ime},\n\nNova usluga '{entity.Naziv}' je sada dostupna u našem salonu. " +
                              $"Dođite i isprobajte je!\n\nVaš eSalon tim"
                };

                await _obavijestService.InsertAsync(obavijest, cancellationToken);
            }
        }

    }
}
