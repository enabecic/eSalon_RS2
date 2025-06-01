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
    public interface IAktiviranaPromocijaService : ICRUDServiceAsync<AktiviranaPromocija, AktiviranaPromocijaSearchObject, AktiviranaPromocijaInsertRequest, AktiviranaPromocijaUpdateRequest>
    {
        Task OznaciKaoIskoristenuAsync(int korisnikId, int promocijaId, CancellationToken cancellationToken = default);
    }
}
