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
    public class UlogaValidator : BaseValidatorService<Database.Uloga>, IUlogaValidator
    {
        private readonly ESalonContext context;

        public UlogaValidator(ESalonContext context) : base(context)
        {
            this.context = context;
        }

        public async Task ValidateInsertAsync(UlogaInsertRequest uloga, CancellationToken cancellationToken = default)
        {
            bool postoji = await context.Ulogas
                .AnyAsync(x => x.Naziv == uloga.Naziv && !x.IsDeleted, cancellationToken);

            if (postoji)
            {
                throw new UserException($"Uloga sa nazivom '{uloga.Naziv}' već postoji!");
            }
        }

        public async Task ValidateUpdateAsync(int id, UlogaUpdateRequest uloga, CancellationToken cancellationToken = default)
        {
            bool postoji = await context.Ulogas
                .AnyAsync(x => x.UlogaId != id && x.Naziv == uloga.Naziv && !x.IsDeleted, cancellationToken);

            if (postoji)
            {
                throw new UserException($"Druga uloga sa nazivom '{uloga.Naziv}' već postoji!");
            }
        }

        public override void ValidateNoDuplicates(List<int> array) 
        {
            if (array == null)
                throw new UserException("Lista uloga ne može biti prazna!");

            if (array.Count != array.Distinct().Count())
                throw new UserException("Ne možete unijeti istu ulogu više puta!"); 
        }
      
    }
}
