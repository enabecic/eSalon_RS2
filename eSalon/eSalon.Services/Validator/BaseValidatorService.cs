using eSalon.Model.Exceptions;
using eSalon.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Validator
{
    public class BaseValidatorService<TEntity> : IBaseValidatorService<TEntity> where TEntity : class
    {
        private readonly ESalonContext context;

        public BaseValidatorService(ESalonContext context)
        {
            this.context = context;
        }


        public virtual async Task ValidateEntityExistsAsync(int id, CancellationToken cancellationToken = default)
        {
            TEntity? entity = await context.Set<TEntity>().FindAsync(id);

            if (entity == null)
                throw new UserException($"Ne postoji {typeof(TEntity).Name} sa id: {id}");
        }

        public virtual void ValidateNoDuplicates(List<int> array)
        {
            if (array == null)
                throw new UserException("Lista je null!");

            if (array.Count != array.Distinct().Count())
                throw new UserException($"Lista {typeof(TEntity).Name} ima duplikate!");

        }
    }
}
