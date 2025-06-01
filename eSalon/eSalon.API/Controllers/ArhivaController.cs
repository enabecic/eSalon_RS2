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
    public class ArhivaController : BaseCRUDControllerAsync<Model.Arhiva, ArhivaSearchObject, ArhivaInsertRequest, ArhivaUpdateRequest>
    {
        private readonly IArhivaService _arhivaService;

        public ArhivaController(IArhivaService arhivaService)
            : base(arhivaService)
        {
            _arhivaService = arhivaService;
        }

        [HttpGet("BrojArhiviranja/{uslugaId}")]
        public async Task<ActionResult<int>> GetBrojArhiviranja(int uslugaId, CancellationToken cancellationToken)
        {
            var brojArhiviranja = await _arhivaService.GetBrojArhiviranjaAsync(uslugaId, cancellationToken);
            return Ok(brojArhiviranja);
        }

        [HttpGet]
        public override Task<PagedResult<Arhiva>> GetList([FromQuery] ArhivaSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        public override Task<Arhiva> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        public override Task<Arhiva> Insert(ArhivaInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        public override Task<Arhiva> Update(int id, ArhivaUpdateRequest request, CancellationToken cancellationToken = default)
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
