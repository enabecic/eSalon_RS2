using Azure.Core;
using eSalon.Model.Exceptions;
using eSalon.Model.Requests;
using eSalon.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.RezervacijaStateMachine
{
    public class KreiranaRezervacijaState : BaseRezervacijaState
    {
        public KreiranaRezervacijaState(ESalonContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override async Task<Model.Rezervacija> Update(int rezervacijaId, RezervacijaUpdateRequest rezervacija, CancellationToken cancellationToken = default)
        {
            var set = Context.Set<Database.Rezervacija>();
            var entity = await set.FindAsync(new object[] { rezervacijaId }, cancellationToken);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena");

            Mapper.Map(rezervacija, entity);
            await Context.SaveChangesAsync(cancellationToken);

            return Mapper.Map<Model.Rezervacija>(entity);
        }

      

        public override async Task<Model.Rezervacija> Odobrena(int rezervacijaId, int frizerId,CancellationToken cancellationToken = default) 
        {
            var set = Context.Set<Database.Rezervacija>();
            var entity = await set.FindAsync(new object[] { rezervacijaId }, cancellationToken);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena");

            if (entity.FrizerId != frizerId)
                throw new UserException("Samo frizer kojem je rezervacija dodijeljena može je odobriti.");

            entity.StateMachine = "odobrena";
            await Context.SaveChangesAsync(cancellationToken);

            return Mapper.Map<Model.Rezervacija>(entity);
        }


        public override async Task<Model.Rezervacija> Ponistena(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            var set = Context.Set<Database.Rezervacija>();
            var entity = await set.FindAsync(new object[] { rezervacijaId }, cancellationToken);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena");

            entity.StateMachine = "ponistena";
            await Context.SaveChangesAsync(cancellationToken);

            return Mapper.Map<Model.Rezervacija>(entity);
        }


        public override List<string> AllowedActions(Rezervacija entity)
        {
            return new List<string>() { nameof(Update), nameof(Odobrena), nameof(Ponistena) };
        }

    }
}
