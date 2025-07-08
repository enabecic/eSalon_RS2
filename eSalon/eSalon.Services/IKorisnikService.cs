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
    public interface IKorisnikService : ICRUDServiceAsync<Korisnik, KorisnikSearchObject, KorisnikInsertRequest, KorisnikUpdateRequest>
    {
        Task<Korisnik> LoginAsync(KorisnikLoginRequest request, CancellationToken cancellationToken = default);
        Task<Korisnik> GetInfoAsync(CancellationToken cancellationToken = default);

    }
}
