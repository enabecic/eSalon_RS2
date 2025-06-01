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
    public class ObavijestController : BaseCRUDControllerAsync<Model.Obavijest, ObavijestSearchObject, ObavijestInsertRequest, ObavijestUpdateRequest>
    {
        private readonly IObavijestService _obavijestService;

        public ObavijestController(IObavijestService obavijestService)
        : base(obavijestService)
        {
            _obavijestService = obavijestService;
        }

        [HttpPut("OznaciKaoProcitanu/{obavijestId}")]
        public async Task<ActionResult> OznaciKaoProcitanuAsync(int obavijestId, CancellationToken cancellationToken)
        {
            await _obavijestService.OznaciKaoProcitanuAsync(obavijestId, cancellationToken);
            return Ok();
        }

        [HttpGet]
        public override Task<PagedResult<Obavijest>> GetList([FromQuery] ObavijestSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        public override Task<Obavijest> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        public override Task<Obavijest> Insert(ObavijestInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        public override Task<Obavijest> Update(int id, ObavijestUpdateRequest request, CancellationToken cancellationToken = default)
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
