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
    public class RecenzijaOdgovorController : BaseCRUDControllerAsync<Model.RecenzijaOdgovor, RecenzijaOdgovorSearchObject, RecenzijaOdgovorInsertRequest, RecenzijaOdgovorUpdateRequest>
    {
        private readonly IRecenzijaOdgovorService _recenzijaOdgovorService;

        public RecenzijaOdgovorController(IRecenzijaOdgovorService recenzijaOdgovorService) : base(recenzijaOdgovorService)
        {
            _recenzijaOdgovorService = recenzijaOdgovorService;
        }

        [HttpPut("ToggleLike/{recenzijaOdgovorId}/{korisnikId}")]
        public async Task<ActionResult> ToggleLikeAsync(int recenzijaOdgovorId, int korisnikId, CancellationToken cancellationToken = default)
        {
            await _recenzijaOdgovorService.ToggleLikeAsync(recenzijaOdgovorId, korisnikId, cancellationToken);
            return Ok();
        }

        [HttpPut("ToggleDislike/{recenzijaOdgovorId}/{korisnikId}")]
        public async Task<ActionResult> ToggleDislikeAsync(int recenzijaOdgovorId, int korisnikId, CancellationToken cancellationToken = default)
        {
            await _recenzijaOdgovorService.ToggleDislikeAsync(recenzijaOdgovorId, korisnikId, cancellationToken);
            return Ok();
        }

        [HttpGet]
        public override Task<PagedResult<RecenzijaOdgovor>> GetList([FromQuery] RecenzijaOdgovorSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        public override Task<RecenzijaOdgovor> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        public override Task<RecenzijaOdgovor> Insert(RecenzijaOdgovorInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        public override Task<RecenzijaOdgovor> Update(int id, RecenzijaOdgovorUpdateRequest request, CancellationToken cancellationToken = default)
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
