using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Validator
{
    public interface IBaseValidatorService<TEntity> where TEntity : class
    {
        Task ValidateEntityExistsAsync(int id, CancellationToken cancellationToken = default);
        void ValidateNoDuplicates(List<int> array);
    }
}
