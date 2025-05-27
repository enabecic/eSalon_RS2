using eSalon.Model.Exceptions;
using eSalon.Model.Requests;
using eSalon.Services.Database;
using eSalon.Services.Validator.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Validator.Implementation
{
    public class KorisnikValidator : BaseValidatorService<Database.Korisnik>, IKorisnikValidator
    {
        private readonly ESalonContext _context;
        public KorisnikValidator(ESalonContext context) : base(context)
        {
            _context = context;
        }

        public async Task ValidateInsertAsync(KorisnikInsertRequest korisnik, CancellationToken cancellationToken = default)
        {
            if (await _context.Korisniks.AnyAsync(x => x.KorisnickoIme == korisnik.KorisnickoIme && !x.IsDeleted, cancellationToken))
                throw new UserException($"Korisničko ime „{korisnik.KorisnickoIme}“ je zauzeto.");

            if (await _context.Korisniks.AnyAsync(x => x.Email == korisnik.Email && !x.IsDeleted, cancellationToken))
                throw new UserException($"E-mail „{korisnik.Email}“ je već registrovan.");

            if (korisnik.Lozinka != korisnik.LozinkaPotvrda)
                throw new UserException("Lozinka i potvrda lozinke nisu identične.");

            if (korisnik.Uloge is null || korisnik.Uloge.Count == 0)
                throw new UserException("Potrebno je odabrati barem jednu ulogu.");
        }

        public async Task ValidateUpdateAsync(int id, KorisnikUpdateRequest korisnik, CancellationToken cancellationToken = default)
        {
            if (!string.IsNullOrWhiteSpace(korisnik.Email))
            {
                bool zauzet = await _context.Korisniks
                    .AnyAsync(x => x.KorisnikId != id && x.Email == korisnik.Email && !x.IsDeleted, cancellationToken);

                if (zauzet)
                    throw new UserException($"Drugi korisnik već koristi e-mail „{korisnik.Email}“.");
            }
        }
    }
}
