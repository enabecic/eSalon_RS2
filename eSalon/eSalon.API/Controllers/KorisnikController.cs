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
    public class KorisnikController : BaseCRUDControllerAsync<Model.Korisnik, KorisnikSearchObject, KorisnikInsertRequest, KorisnikUpdateRequest>
    {
        private readonly IKorisnikService _korisnikService;
        public KorisnikController(IKorisnikService korisnikService) : base(korisnikService)
        {
            _korisnikService = korisnikService;
        }

        [HttpPost("login")]
        public async Task<ActionResult<Model.Korisnik>> Login([FromBody] KorisnikLoginRequest request, CancellationToken cancellationToken)
        {
            var dto = await _korisnikService.LoginAsync(request, cancellationToken);
            return Ok(dto);
        }

        [HttpGet]
        public override Task<PagedResult<Korisnik>> GetList([FromQuery] KorisnikSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        public override Task<Korisnik> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        public override Task<Korisnik> Insert(KorisnikInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        public override Task<Korisnik> Update(int id, KorisnikUpdateRequest request, CancellationToken cancellationToken = default)
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
