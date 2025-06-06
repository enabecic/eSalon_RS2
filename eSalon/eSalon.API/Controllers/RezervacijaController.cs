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
    public class RezervacijaController : BaseCRUDControllerAsync<Model.Rezervacija, RezervacijaSearchObject, RezervacijaInsertRequest, RezervacijaUpdateRequest>
    {
        private readonly IRezervacijaService _rezervacijaService;

        public RezervacijaController(IRezervacijaService rezervacijaService)
             : base(rezervacijaService)
        {
            _rezervacijaService = rezervacijaService;
        }

        [HttpPut("{rezervacijaId}/odobri")]
        public async Task<Model.Rezervacija> Odobri(int rezervacijaId, int frizerId, CancellationToken cancellationToken = default)
        {
            return await _rezervacijaService.OdobriAsync(rezervacijaId, frizerId, cancellationToken);
        }

        [HttpPut("{rezervacijaId}/ponisti")]
        public async Task<Model.Rezervacija> Ponisti(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            return await _rezervacijaService.PonistiAsync(rezervacijaId, cancellationToken);
        }

        [HttpPut("{rezervacijaId}/zavrsi")]
        public async Task<Model.Rezervacija> Zavrsi(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            return await _rezervacijaService.ZavrsiAsync(rezervacijaId, cancellationToken);
        }

        [HttpGet("{rezervacijaId}/allowedActions")]
        public Task<List<string>> AllowedActions(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            return _rezervacijaService.AllowedActionsAsync(rezervacijaId, cancellationToken);
        }

        [HttpPost("provjeri-termin")]
        public async Task<IActionResult> ProvjeriTermin(RezervacijaInsertRequest request, CancellationToken cancellationToken = default)
        {
            var poruka = await _rezervacijaService.ProvjeriTerminAsync(request, cancellationToken);
            return Ok(poruka);
        }

        [HttpGet]
        public override Task<PagedResult<Rezervacija>> GetList([FromQuery] RezervacijaSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        public override Task<Rezervacija> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        public override Task<Rezervacija> Insert(RezervacijaInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        public override Task<Rezervacija> Update(int id, RezervacijaUpdateRequest request, CancellationToken cancellationToken = default)
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
