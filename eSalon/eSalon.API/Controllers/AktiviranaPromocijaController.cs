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
    public class AktiviranaPromocijaController : BaseCRUDControllerAsync<Model.AktiviranaPromocija, AktiviranaPromocijaSearchObject, AktiviranaPromocijaInsertRequest, AktiviranaPromocijaUpdateRequest>
    {
        private readonly IAktiviranaPromocijaService _aktiviranaPromocijaService;
        public AktiviranaPromocijaController(IAktiviranaPromocijaService aktiviranaPromocijaService)
        : base(aktiviranaPromocijaService)
        {
            _aktiviranaPromocijaService=aktiviranaPromocijaService;
        }

        [HttpPut("Iskoristi")]
        [Authorize(Roles = "Klijent")]
        public async Task<ActionResult> OznačiKaoIskoritenuAsync([FromQuery] int korisnikId, [FromQuery] int promocijaId, CancellationToken cancellationToken)
        {
            await _aktiviranaPromocijaService.OznaciKaoIskoristenuAsync(korisnikId, promocijaId, cancellationToken);
            return Ok();
        }


        [HttpGet]
        [Authorize(Roles = "Admin,Klijent")]
        public override Task<PagedResult<AktiviranaPromocija>> GetList([FromQuery] AktiviranaPromocijaSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Admin,Klijent")]
        public override Task<AktiviranaPromocija> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        [Authorize(Roles = "Klijent")]
        public override Task<AktiviranaPromocija> Insert(AktiviranaPromocijaInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Klijent")]
        public override Task<AktiviranaPromocija> Update(int id, AktiviranaPromocijaUpdateRequest request, CancellationToken cancellationToken = default)
        {
            return base.Update(id, request, cancellationToken);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,Klijent")]
        public override Task Delete(int id, CancellationToken cancellationToken = default)
        {
            return base.Delete(id, cancellationToken);
        }
    }
}
