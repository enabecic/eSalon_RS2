using eSalon.Model.Exceptions;
using eSalon.Model.Requests;
using eSalon.Services.Database;
using eSalon.Services.Validator.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Validator.Implementation
{
    public class RezervacijaValidator : BaseValidatorService<Database.Rezervacija>, IRezervacijaValidator
    {
        public RezervacijaValidator(ESalonContext context) : base(context)
        {
        }

        public Task ValidateInsertAsync(RezervacijaInsertRequest rezervacija, CancellationToken cancellationToken = default)
        {

            if (rezervacija.StavkeRezervacije == null || rezervacija.StavkeRezervacije.Count == 0)
                throw new UserException("Rezervacija mora sadržavati barem jednu uslugu.");

            var duplikati = rezervacija.StavkeRezervacije
                .GroupBy(s => s.UslugaId)
                .Where(g => g.Count() > 1)
                .Select(g => g.Key)
                .ToList();

            if (duplikati.Any())
                throw new UserException("Ne možete dodati istu uslugu više puta u jednu rezervaciju.");

            if (rezervacija.DatumRezervacije.Date < DateTime.Now.Date)
                throw new UserException("Datum rezervacije mora biti u budućnosti.");

            return Task.CompletedTask;
        }
    }
}
