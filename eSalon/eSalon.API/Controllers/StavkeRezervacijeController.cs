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
    public class StavkeRezervacijeController : BaseCRUDControllerAsync<Model.StavkeRezervacije, StavkeRezervacijeSearchObject, StavkeRezervacijeInsertRequest, StavkeRezervacijeUpdateRequest>
    {
        public StavkeRezervacijeController(IStavkeRezervacijeService service)
             : base(service)
        {
        }


    }
}
