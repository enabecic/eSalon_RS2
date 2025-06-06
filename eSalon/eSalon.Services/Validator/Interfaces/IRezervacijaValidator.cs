using eSalon.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Validator.Interfaces
{
    public interface IRezervacijaValidator : IBaseValidatorService<Database.Rezervacija>
    {
        Task ValidateInsertAsync(RezervacijaInsertRequest rezervacija, CancellationToken cancellationToken = default);
    }
}
