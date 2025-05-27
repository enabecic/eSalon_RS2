using eSalon.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Validator.Interfaces
{
    public interface IKorisnikValidator : IBaseValidatorService<Database.Korisnik>
    {
        Task ValidateInsertAsync(KorisnikInsertRequest korisnik, CancellationToken cancellationToken = default);
        Task ValidateUpdateAsync(int id, KorisnikUpdateRequest korisnik, CancellationToken cancellationToken = default);
    }
}
