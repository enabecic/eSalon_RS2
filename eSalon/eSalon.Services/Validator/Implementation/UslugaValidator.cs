using Azure.Core;
using eSalon.Model.Exceptions;
using eSalon.Model.Requests;
using eSalon.Services.Database;
using eSalon.Services.Validator.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core.Tokenizer;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Validator.Implementation
{
    public class UslugaValidator : BaseValidatorService<Database.Usluga>, IUslugaValidator
    {
        private readonly ESalonContext _context;
        public UslugaValidator(ESalonContext context) : base(context)
        {
            _context = context;
        }
        public async Task ValidateInsertAsync(UslugaInsertRequest usluga, CancellationToken cancellationToken = default)
        {
            bool postoji = await _context.Uslugas.AnyAsync(
            x => x.Naziv == usluga.Naziv &&
            x.VrstaId == usluga.VrstaId && !x.IsDeleted, cancellationToken);

            if (postoji)
                throw new UserException($"Usluga „{usluga.Naziv}“ vrste #{usluga.VrstaId} već postoji!");


            if (usluga.Cijena <= 0)
                throw new UserException("Cijena mora biti veća od 0.");

            if (usluga.Trajanje <= 0)
                throw new UserException("Trajanje mora biti veća od 0.");

        }

        public async Task ValidateUpdateAsync(int id, UslugaUpdateRequest usluga, CancellationToken cancellationToken = default)
        {
            bool postoji = await _context.Uslugas.AnyAsync(
         x => x.UslugaId != id &&
              x.Naziv == usluga.Naziv &&
              x.VrstaId == usluga.VrstaId &&
              !x.IsDeleted,
         cancellationToken);

            if (postoji)
                throw new UserException(
                    $"Druga usluga „{usluga.Naziv}“ iste vrste već postoji!");


            if (usluga.Cijena <= 0)
                throw new UserException("Cijena mora biti veća od 0.");


            if (usluga.Trajanje <= 0)
                throw new UserException("Trajanje mora biti veća od 0.");
        }
    }
}
