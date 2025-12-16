using eSalon.Model.Exceptions;
using eSalon.Model.Requests;
using eSalon.Services.Database;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.RezervacijaStateMachine
{
    public class BaseRezervacijaState
    {
        public ESalonContext Context { get; set; }
        public IMapper Mapper { get; set; }
        public IServiceProvider ServiceProvider { get; set; }

        public BaseRezervacijaState(ESalonContext context, IMapper mapper, IServiceProvider serviceProvider)
        {
            Context = context;
            Mapper = mapper;
            ServiceProvider = serviceProvider;
        }

        public virtual async Task<Model.Rezervacija> Insert(RezervacijaInsertRequest rezervacija, CancellationToken cancellationToken = default)
        {
            await Task.CompletedTask;
            throw new UserException("Metoda nije dozvoljena.");
        }
        public virtual async Task<Model.Rezervacija> Update(int rezervacijaId, RezervacijaUpdateRequest rezervacija, CancellationToken cancellationToken = default)
        {
            await Task.CompletedTask;
            throw new UserException("Metoda nije dozvoljena.");
        }
        public virtual async Task<Model.Rezervacija> Kreirana(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            await Task.CompletedTask;
            throw new UserException("Metoda nije dozvoljena.");
        }
        public virtual async Task<Model.Rezervacija> Ponistena(int rezervacijaId, int korisnikId, CancellationToken cancellationToken = default)
        {
            await Task.CompletedTask;
            throw new UserException("Metoda nije dozvoljena.");
        }
        public virtual async Task<Model.Rezervacija> Odobrena(int rezervacijaId, int frizerId, CancellationToken cancellationToken = default)
        {
            await Task.CompletedTask;
            throw new UserException("Metoda nije dozvoljena.");
        }
        public virtual async Task<Model.Rezervacija> Zavrsena(int rezervacijaId, CancellationToken cancellationToken = default)
        {
            await Task.CompletedTask;
            throw new UserException("Metoda nije dozvoljena.");
        }
        public virtual List<string> AllowedActions(Database.Rezervacija entity)
        {
            throw new UserException("Metoda nije dozvoljena.");
        }

        public BaseRezervacijaState CreateState(string stateName)
        {
            BaseRezervacijaState? state = stateName switch
            {
                "initial" => ServiceProvider.GetService<InitialRezervacijaState>(),
                "kreirana" => ServiceProvider.GetService<KreiranaRezervacijaState>(),
                "odobrena" => ServiceProvider.GetService<OdobrenaRezervacijaState>(),
                "ponistena" => ServiceProvider.GetService<PonistenaRezervacijaState>(),
                "zavrsena" => ServiceProvider.GetService<ZavrsenaRezervacijaState>(),
                _ => null
            };

            if (state == null)
                throw new UserException("Greška prilikom prepoznavanja stanja rezervacije.");

            return state;
        }

    }
}
