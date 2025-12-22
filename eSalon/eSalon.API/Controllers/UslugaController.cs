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
    public class UslugaController : BaseCRUDControllerAsync<Model.Usluga, UslugaSearchObject, UslugaInsertRequest, UslugaUpdateRequest>
    {
        public UslugaController(IUslugaService service)
      : base(service)
        {
        }


        [AllowAnonymous]
        [HttpGet("{uslugaId}/recommended")]
        public Task<List<Model.Usluga>> Recommend(int uslugaId)
        {
            return (_service as IUslugaService).Recommend(uslugaId);
        }
        [AllowAnonymous]
        [HttpGet("traindata")]
        public void TrainData()
        {
            (_service as IUslugaService).TrainData();
        }

        [HttpGet]
        [AllowAnonymous]
        public override Task<PagedResult<Usluga>> GetList([FromQuery] UslugaSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override Task<Usluga> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override Task<Usluga> Insert(UslugaInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override Task<Usluga> Update(int id, UslugaUpdateRequest request, CancellationToken cancellationToken = default)
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
