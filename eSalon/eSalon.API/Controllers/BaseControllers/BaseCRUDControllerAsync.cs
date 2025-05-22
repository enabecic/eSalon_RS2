using eSalon.Model.SearchObjects;
using eSalon.Services.BaseServicesInterfaces;
using Microsoft.AspNetCore.Mvc;

namespace eSalon.API.Controllers.BaseControllers
{
    [ApiController]
    [Route("api/[controller]")]
   
    public class BaseCRUDControllerAsync<TModel, TSearch, TInsert, TUpdate> : BaseControllerAsync<TModel, TSearch> where TSearch : BaseSearchObject where TModel : class
    {
        protected new ICRUDServiceAsync<TModel, TSearch, TInsert, TUpdate> _service;

        public BaseCRUDControllerAsync(ICRUDServiceAsync<TModel, TSearch, TInsert, TUpdate> service) : base(service)
        {
            _service = service;
        }

        [HttpPost]
        public virtual Task<TModel> Insert(TInsert request, CancellationToken cancellationToken = default)
        {
            return _service.InsertAsync(request, cancellationToken);
        }

        [HttpPut("{id}")]
        public virtual Task<TModel> Update(int id, TUpdate request, CancellationToken cancellationToken = default)
        {
            return _service.UpdateAsync(id, request, cancellationToken);
        }

        [HttpDelete("{id}")]
        public virtual Task Delete(int id, CancellationToken cancellationToken = default)
        {
            return _service.DeleteAsync(id, cancellationToken);
        }
    }
}
