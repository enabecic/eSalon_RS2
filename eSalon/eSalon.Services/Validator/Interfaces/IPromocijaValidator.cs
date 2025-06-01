using eSalon.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Validator.Interfaces
{
    public interface IPromocijaValidator : IBaseValidatorService<Database.Promocija>
    {
        Task ValidateInsertAsync(PromocijaInsertRequest promocija, CancellationToken cancellationToken = default);
        Task ValidateUpdateAsync(int id, PromocijaUpdateRequest promocija, CancellationToken cancellationToken = default);
    }
}
