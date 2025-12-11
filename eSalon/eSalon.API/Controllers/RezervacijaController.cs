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
    public class RezervacijaController : BaseCRUDControllerAsync<Model.Rezervacija, RezervacijaSearchObject, RezervacijaInsertRequest, RezervacijaUpdateRequest>
    {
        private readonly IRezervacijaService _rezervacijaService;

        public RezervacijaController(IRezervacijaService rezervacijaService)
             : base(rezervacijaService)
        {
            _rezervacijaService = rezervacijaService;
        }

        [HttpPut("{rezervacijaId}/odobri/{frizerId}")]
        [Authorize(Roles = "Frizer")]
        public async Task<Model.Rezervacija> Odobri(int rezervacijaId, int frizerId, CancellationToken cancellationToken = default)
        {
            return await _rezervacijaService.OdobriAsync(rezervacijaId, frizerId, cancellationToken);
        }

        [HttpPut("{rezervacijaId}/ponisti")]
        [Authorize(Roles = "Klijent,Frizer")]
        public async Task<Model.Rezervacija> Ponisti(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            return await _rezervacijaService.PonistiAsync(rezervacijaId, cancellationToken);
        }

        [HttpPut("{rezervacijaId}/zavrsi")]
        [Authorize(Roles = "Frizer")]
        public async Task<Model.Rezervacija> Zavrsi(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            return await _rezervacijaService.ZavrsiAsync(rezervacijaId, cancellationToken);
        }

        [HttpGet("{rezervacijaId}/allowedActions")]
        [Authorize(Roles = "Klijent,Admin,Frizer")]
        public Task<List<string>> AllowedActions(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            return _rezervacijaService.AllowedActionsAsync(rezervacijaId, cancellationToken);
        }

        [Authorize(Roles = "Klijent")]
        [HttpGet("zauzeti-termini")]
        public async Task<ActionResult<List<object>>> GetZauzetiTermini([FromQuery] int frizerId, [FromQuery] DateTime datumRezervacije, CancellationToken cancellationToken = default)
        {
            var zauzetiTermini = await _rezervacijaService.GetZauzetiTerminiZaDatumAsync(datumRezervacije, frizerId, cancellationToken);

            var result = zauzetiTermini.Select(t => new
            {
                VrijemePocetka = t.VrijemePocetka.ToString(@"hh\:mm"),
                VrijemeKraja = t.VrijemeKraja.ToString(@"hh\:mm")
            }).ToList();

            return Ok(result);
        }

        [HttpPost("provjeri-termin")]
        [Authorize(Roles = "Klijent")]
        public async Task<IActionResult> ProvjeriTermin(RezervacijaInsertRequest request, CancellationToken cancellationToken = default)
        {
            await _rezervacijaService.ProvjeriTerminAsync(request, cancellationToken);
            return Ok();
        }

        [HttpGet("kalendar")]
        [Authorize(Roles = "Klijent")]
        public async Task<IActionResult> GetKalendar([FromQuery] int frizerId, [FromQuery] int godina, [FromQuery] int mjesec, CancellationToken cancellationToken)
        {
            var result = await _rezervacijaService.GetKalendarAsync(frizerId, godina, mjesec, cancellationToken);
            return Ok(result);
        }


        [HttpGet]
        [Authorize(Roles = "Klijent,Admin,Frizer")]
        public override Task<PagedResult<Rezervacija>> GetList([FromQuery] RezervacijaSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Klijent,Admin,Frizer")]
        public override Task<Rezervacija> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        [Authorize(Roles = "Klijent")]
        public override Task<Rezervacija> Insert(RezervacijaInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Klijent")]
        public override Task<Rezervacija> Update(int id, RezervacijaUpdateRequest request, CancellationToken cancellationToken = default)
        {
            return base.Update(id, request, cancellationToken);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Klijent")]
        public override Task Delete(int id, CancellationToken cancellationToken = default)
        {
            return base.Delete(id, cancellationToken);
        }
    }
}
