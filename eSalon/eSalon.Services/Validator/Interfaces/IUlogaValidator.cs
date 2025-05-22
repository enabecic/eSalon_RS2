using eSalon.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Validator.Interfaces
{
    public interface IUlogaValidator : IBaseValidatorService<Database.Uloga>
    {
        Task ValidateInsertAsync(UlogaInsertRequest uloga, CancellationToken cancellationToken = default);
        Task ValidateUpdateAsync(int id, UlogaUpdateRequest uloga, CancellationToken cancellationToken = default);
    }
}
