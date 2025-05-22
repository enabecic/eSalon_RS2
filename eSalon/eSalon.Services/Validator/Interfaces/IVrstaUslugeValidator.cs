using eSalon.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Validator.Interfaces
{
    public interface IVrstaUslugeValidator : IBaseValidatorService<Database.VrstaUsluge>
    {
        Task ValidateInsertAsync(VrstaUslugeInsertRequest vrstaUsluge, CancellationToken cancellationToken = default);
        Task ValidateUpdateAsync(int id, VrstaUslugeUpdateRequest vrstaUsluge, CancellationToken cancellationToken = default);
    }
}
