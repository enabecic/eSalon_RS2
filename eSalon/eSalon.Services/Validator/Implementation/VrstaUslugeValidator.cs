using eSalon.Model;
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
    public class VrstaUslugeValidator : BaseValidatorService<Database.VrstaUsluge>, IVrstaUslugeValidator
    {
        private readonly ESalonContext context;
        public VrstaUslugeValidator(ESalonContext context) : base(context)
        {
            this.context = context;
        }

        public async Task ValidateInsertAsync(VrstaUslugeInsertRequest vrstaUsluge, CancellationToken cancellationToken = default)
        {
            bool postoji = await context.VrstaUsluges
              .AnyAsync(x => x.Naziv == vrstaUsluge.Naziv && !x.IsDeleted, cancellationToken);

            if (postoji)
            {
                throw new UserException($"Vrsta usluge sa nazivom '{vrstaUsluge.Naziv}' već postoji!");
            }
        }

        public async Task ValidateUpdateAsync(int id, VrstaUslugeUpdateRequest vrstaUsluge, CancellationToken cancellationToken = default)
        {
            bool postoji = await context.VrstaUsluges
             .AnyAsync(x => x.VrstaId != id && x.Naziv == vrstaUsluge.Naziv && !x.IsDeleted, cancellationToken);

            if (postoji)
            {
                throw new UserException($"Druga vrsta usluge sa nazivom '{vrstaUsluge.Naziv}' već postoji!");
            }
        }
    }
}
