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
    public class PromocijaValidator : BaseValidatorService<Database.Promocija>, IPromocijaValidator
    {
        private readonly ESalonContext _context;
        public PromocijaValidator(ESalonContext context) : base(context)
        {
            _context = context;
        }

        public async Task ValidateInsertAsync(PromocijaInsertRequest promocija, CancellationToken cancellationToken = default)
        {
            bool postoji = await _context.Promocijas.AnyAsync(
            x => x.Naziv == promocija.Naziv &&
            x.UslugaId == promocija.UslugaId && x.DatumPocetka.Date==promocija.DatumPocetka.Date && x.DatumKraja.Date==promocija.DatumKraja.Date && !x.IsDeleted, cancellationToken);

            if (postoji)
                throw new UserException($"Promocija „{promocija.Naziv}“ usluge #{promocija.UslugaId} sa datumom početka {promocija.DatumPocetka} i datumom kraja {promocija.DatumKraja} već postoji!");
            
            if (promocija.DatumPocetka.Date < DateTime.Now.Date)
                throw new UserException("Datum početka ne može biti u prošlosti.");


            if (promocija.DatumKraja.Date <= promocija.DatumPocetka.Date)
                throw new UserException("Datum kraja mora biti nakon datuma početka.");
        }

        public async Task ValidateUpdateAsync(int id, PromocijaUpdateRequest promocija, CancellationToken cancellationToken = default)
        {
            bool postoji = await _context.Promocijas.AnyAsync(
            x => x.PromocijaId != id &&
           x.Naziv == promocija.Naziv &&
           x.UslugaId == promocija.UslugaId &&
           x.DatumPocetka.Date == promocija.DatumPocetka.Date && 
           x.DatumKraja.Date == promocija.DatumKraja.Date &&
           !x.IsDeleted,
      cancellationToken);

            if (postoji)
                throw new UserException(
                    $"Druga promocija „{promocija.Naziv}“ iste usluge i istog datuma početka i kraja već postoji!");


            if (promocija.DatumKraja.Date <= promocija.DatumPocetka.Date)
                throw new UserException("Datum kraja mora biti nakon datuma početka.");

            //if (promocija.DatumKraja.Date < DateTime.Now.Date)
            //    throw new UserException("Datum kraja ne može biti u prošlosti.");
        }
    }
}
