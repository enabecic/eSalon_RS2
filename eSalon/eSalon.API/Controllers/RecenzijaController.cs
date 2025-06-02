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
    public class RecenzijaController : BaseCRUDControllerAsync<Model.Recenzija, RecenzijaSearchObject, RecenzijaInsertRequest, RecenzijaUpdateRequest>
    {
        private readonly IRecenzijaService _recenzijaService;
        public RecenzijaController(IRecenzijaService recenzijaService)
            : base(recenzijaService)
        {
            _recenzijaService = recenzijaService;
        }

        [HttpPut("ToggleLike/{recenzijaId}/{korisnikId}")]
        public async Task<ActionResult> ToggleLikeAsync(int recenzijaId, int korisnikId, CancellationToken cancellationToken = default)
        {
            await _recenzijaService.ToggleLikeAsync(recenzijaId, korisnikId, cancellationToken);
            return Ok();
        }

        [HttpPut("ToggleDislike/{recenzijaId}/{korisnikId}")]
        public async Task<ActionResult> ToggleDislikeAsync(int recenzijaId, int korisnikId, CancellationToken cancellationToken = default)
        {
            await _recenzijaService.ToggleDislikeAsync(recenzijaId, korisnikId, cancellationToken);
            return Ok();
        }

        [HttpGet]
        public override Task<PagedResult<Recenzija>> GetList([FromQuery] RecenzijaSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        public override Task<Recenzija> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        public override Task<Recenzija> Insert(RecenzijaInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        public override Task<Recenzija> Update(int id, RecenzijaUpdateRequest request, CancellationToken cancellationToken = default)
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
