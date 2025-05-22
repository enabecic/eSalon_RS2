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
    public class VrstaUslugeController : BaseCRUDControllerAsync<Model.VrstaUsluge, VrstaUslugeSearchObject, VrstaUslugeInsertRequest,VrstaUslugeUpdateRequest>
    {

        public VrstaUslugeController(IVrstaUslugeService service)
       : base(service)
        {
        }

        [HttpGet]
        public override Task<PagedResult<VrstaUsluge>> GetList([FromQuery] VrstaUslugeSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [HttpGet("{id}")]
        public override Task<VrstaUsluge> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }

        [HttpPost]
        public override Task<VrstaUsluge> Insert(VrstaUslugeInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [HttpPut("{id}")]
        public override Task<VrstaUsluge> Update(int id, VrstaUslugeUpdateRequest request, CancellationToken cancellationToken = default)
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
