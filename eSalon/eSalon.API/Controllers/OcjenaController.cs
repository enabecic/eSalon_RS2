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
    public class OcjenaController : BaseCRUDControllerAsync<Model.Ocjena, OcjenaSearchObject, OcjenaInsertRequest, OcjenaUpdateRequest>
    {
        private readonly IOcjenaService _ocjenaService;

        public OcjenaController(IOcjenaService ocjenaService) : base(ocjenaService)
        {
            _ocjenaService = ocjenaService;
        }

        [HttpGet("Prosjek/{uslugaId}")]
        public async Task<ActionResult<double>> GetProsjekOcjena(int uslugaId, CancellationToken cancellationToken)
        {
            var prosjek = await _ocjenaService.GetProsjekOcjenaAsync(uslugaId, cancellationToken);
            return Ok(prosjek);
        }


        [HttpGet]
        public override Task<PagedResult<Ocjena>> GetList([FromQuery] OcjenaSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        public override Task<Ocjena> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        public override Task<Ocjena> Insert(OcjenaInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        public override Task<Ocjena> Update(int id, OcjenaUpdateRequest request, CancellationToken cancellationToken = default)
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
