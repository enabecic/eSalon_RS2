using eSalon.API.Controllers.BaseControllers;
using eSalon.Model;
using eSalon.Model.Requests;
using eSalon.Model.SearchObjects;
using eSalon.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eSalon.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PromocijaController : BaseCRUDControllerAsync<Model.Promocija, PromocijaSearchObject, PromocijaInsertRequest, PromocijaUpdateRequest>
    {
        public PromocijaController(IPromocijaService service)
         : base(service)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override Task<PagedResult<Promocija>> GetList([FromQuery] PromocijaSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override Task<Promocija> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override Task<Promocija> Insert(PromocijaInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override Task<Promocija> Update(int id, PromocijaUpdateRequest request, CancellationToken cancellationToken = default)
        {
            return base.Update(id, request, cancellationToken);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public override Task Delete(int id, CancellationToken cancellationToken = default)
        {
            return base.Delete(id, cancellationToken);
        }

    }
}
