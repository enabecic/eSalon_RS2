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
    public class StavkeRezervacijeController : BaseCRUDControllerAsync<Model.StavkeRezervacije, StavkeRezervacijeSearchObject, StavkeRezervacijeInsertRequest, StavkeRezervacijeUpdateRequest>
    {
        public StavkeRezervacijeController(IStavkeRezervacijeService service)
             : base(service)
        {
        }

        [HttpGet]
        public override Task<PagedResult<StavkeRezervacije>> GetList([FromQuery] StavkeRezervacijeSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        public override Task<StavkeRezervacije> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        public override Task<StavkeRezervacije> Insert(StavkeRezervacijeInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        public override Task<StavkeRezervacije> Update(int id, StavkeRezervacijeUpdateRequest request, CancellationToken cancellationToken = default)
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
