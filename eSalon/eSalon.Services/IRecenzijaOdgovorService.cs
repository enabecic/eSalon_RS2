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
    public interface IRecenzijaOdgovorService : ICRUDServiceAsync<RecenzijaOdgovor, RecenzijaOdgovorSearchObject, RecenzijaOdgovorInsertRequest, RecenzijaOdgovorUpdateRequest>
    {
        Task ToggleLikeAsync(int recenzijaOdgovorId, int korisnikId, CancellationToken cancellationToken = default);
        Task ToggleDislikeAsync(int recenzijaOdgovorId, int korisnikId, CancellationToken cancellationToken = default);
    }
}
