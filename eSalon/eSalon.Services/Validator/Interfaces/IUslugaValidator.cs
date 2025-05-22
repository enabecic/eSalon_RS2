using eSalon.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Validator.Interfaces
{
    public interface IUslugaValidator: IBaseValidatorService<Database.Usluga>
    {
        Task ValidateInsertAsync(UslugaInsertRequest usluga, CancellationToken cancellationToken = default);
        Task ValidateUpdateAsync(int id, UslugaUpdateRequest usluga, CancellationToken cancellationToken = default);
    }
}
