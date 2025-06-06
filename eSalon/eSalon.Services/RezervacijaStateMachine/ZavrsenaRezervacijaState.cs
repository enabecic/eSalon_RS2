using eSalon.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.RezervacijaStateMachine
{
    public class ZavrsenaRezervacijaState : BaseRezervacijaState
    {
        public ZavrsenaRezervacijaState(ESalonContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override List<string> AllowedActions(Rezervacija entity)
        {
            return new List<string>();
        }
    }
}
