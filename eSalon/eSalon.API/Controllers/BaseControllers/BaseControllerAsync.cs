using eSalon.Model;
using eSalon.Model.SearchObjects;
using eSalon.Services.BaseServicesInterfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eSalon.API.Controllers.BaseControllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]

    public class BaseControllerAsync<TModel, TSearch> : ControllerBase where TSearch : BaseSearchObject
    {

        private readonly IServiceAsync<TModel, TSearch> _service;

        public BaseControllerAsync(IServiceAsync<TModel, TSearch> service)
        {
            _service = service;
        }

        [HttpGet]
        public virtual Task<PagedResult<TModel>> GetList([FromQuery] TSearch searchObject, CancellationToken cancellationToken = default)
        {
            return _service.GetPagedAsync(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        public virtual Task<TModel> GetById(int id, CancellationToken cancellationToken = default)
        {
            return _service.GetByIdAsync(id, cancellationToken);
        }
    }
}
