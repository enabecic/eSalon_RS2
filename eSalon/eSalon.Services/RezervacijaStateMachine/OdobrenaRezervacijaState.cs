using eSalon.Model.Exceptions;
using eSalon.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.RezervacijaStateMachine
{
    public class OdobrenaRezervacijaState : BaseRezervacijaState
    {
        public OdobrenaRezervacijaState(ESalonContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override async Task<Model.Rezervacija> Zavrsena(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            var set = Context.Set<Database.Rezervacija>();
            var entity = await set.FindAsync(new object[] { rezervacijaId }, cancellationToken);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            entity.StateMachine = "zavrsena";
            await Context.SaveChangesAsync(cancellationToken);

            return Mapper.Map<Model.Rezervacija>(entity);
        }

        public override List<string> AllowedActions(Rezervacija entity)
        {
            return new List<string>() { nameof(Zavrsena) };
        }
    }
}
