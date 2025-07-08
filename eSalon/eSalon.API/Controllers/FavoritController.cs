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
    public class FavoritController : BaseCRUDControllerAsync<Model.Favorit, FavoritSearchObject, FavoritInsertRequest, FavoritUpdateRequest>
    {
        public FavoritController(IFavoritService service)
         : base(service)
        {
        }

        [HttpGet]
        [Authorize(Roles = "Klijent")]
        public override Task<PagedResult<Favorit>> GetList([FromQuery] FavoritSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Klijent")]
        public override Task<Favorit> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        [Authorize(Roles = "Klijent")]
        public override Task<Favorit> Insert(FavoritInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Klijent")]
        public override Task<Favorit> Update(int id, FavoritUpdateRequest request, CancellationToken cancellationToken = default)
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
