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

    public class UlogaController : BaseCRUDControllerAsync<Model.Uloga, UlogaSearchObject, UlogaInsertRequest, UlogaUpdateRequest>
    {
        public UlogaController(IUlogaService service)
       : base(service)
        {
        }

        [HttpGet]
        [Authorize(Roles = "Klijent,Admin,Frizer")]
        public override Task<PagedResult<Uloga>> GetList([FromQuery] UlogaSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Klijent,Admin,Frizer")]
        public override Task<Uloga> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override Task<Uloga> Insert(UlogaInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override Task<Uloga> Update(int id, UlogaUpdateRequest request, CancellationToken cancellationToken = default)
        {
            return base.Update(id, request, cancellationToken);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public override Task Delete(int id, CancellationToken cancellationToken = default)
        {
            return base.Delete(id, cancellationToken);
        }

    }
}
