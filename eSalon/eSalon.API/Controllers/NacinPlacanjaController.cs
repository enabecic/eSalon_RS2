using eSalon.API.Controllers.BaseControllers;
using eSalon.Model;
using eSalon.Model.Requests;
using eSalon.Model.SearchObjects;
using eSalon.Services;
using Microsoft.AspNetCore.Mvc;

namespace eSalon.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NacinPlacanjaController : BaseCRUDControllerAsync<Model.NacinPlacanja, NacinPlacanjaSearchObject, NacinPlacanjaInsertRequest, NacinPlacanjaIUpdateRequest>
    {

        public NacinPlacanjaController(INacinPlacanjaService service)
     : base(service)
        {
        }

        [HttpGet]
        public override Task<PagedResult<NacinPlacanja>> GetList([FromQuery] NacinPlacanjaSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        public override Task<NacinPlacanja> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        public override Task<NacinPlacanja> Insert(NacinPlacanjaInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        public override Task<NacinPlacanja> Update(int id, NacinPlacanjaIUpdateRequest request, CancellationToken cancellationToken = default)
        {
            return base.Update(id, request, cancellationToken);
        }

        [HttpDelete("{id}")]
        public override Task Delete(int id, CancellationToken cancellationToken = default)
        {
            return base.Delete(id, cancellationToken);
        }

    }
}
