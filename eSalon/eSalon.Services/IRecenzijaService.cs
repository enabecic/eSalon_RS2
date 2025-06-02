using eSalon.Model;
using eSalon.Model.Requests;
using eSalon.Model.SearchObjects;
using eSalon.Services.BaseServicesInterfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services
{
    public interface IRecenzijaService : ICRUDServiceAsync<Recenzija, RecenzijaSearchObject, RecenzijaInsertRequest, RecenzijaUpdateRequest>
    {
        Task ToggleLikeAsync(int recenzijaId, int korisnikId, CancellationToken cancellationToken = default);
        Task ToggleDislikeAsync(int recenzijaId, int korisnikId, CancellationToken cancellationToken = default);
    }
}
