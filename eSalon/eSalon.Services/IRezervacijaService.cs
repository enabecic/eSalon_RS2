﻿using eSalon.Model;
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
    public interface IRezervacijaService : ICRUDServiceAsync<Rezervacija, RezervacijaSearchObject, RezervacijaInsertRequest, RezervacijaUpdateRequest>
    {
        Task<Rezervacija> OdobriAsync(int rezervacijaId, int frizerId, CancellationToken cancellationToken = default);

        Task<Rezervacija> ZavrsiAsync(int rezervacijaId, CancellationToken cancellationToken = default);

        Task<Rezervacija> PonistiAsync(int rezervacijaId, CancellationToken cancellationToken = default);

        Task<List<string>> AllowedActionsAsync(int rezervacijaId, CancellationToken cancellationToken = default);

        Task<string> ProvjeriTerminAsync(RezervacijaInsertRequest rezervacija, CancellationToken cancellationToken = default);


    }
}
