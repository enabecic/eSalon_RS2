using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class Rezervacija : ISoftDelete
{
    public int RezervacijaId { get; set; }

    public int KorisnikId { get; set; }

    public int FrizerId { get; set; }

    public string Sifra { get; set; } = null!;

    public DateTime DatumRezervacije { get; set; }

    public TimeSpan VrijemePocetka { get; set; }

    public TimeSpan? VrijemeKraja { get; set; }
    public bool TerminZatvoren { get; set; }

    public decimal UkupnaCijena { get; set; }

    public int? UkupnoTrajanje { get; set; }

    public int? UkupanBrojUsluga { get; set; }

    public string? StateMachine { get; set; }

    public int NacinPlacanjaId { get; set; }

    public int? AktiviranaPromocijaId { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual AktiviranaPromocija? AktiviranaPromocija { get; set; }

    public virtual Korisnik Frizer { get; set; } = null!;

    public virtual Korisnik Korisnik { get; set; } = null!;

    public virtual NacinPlacanja NacinPlacanja { get; set; } = null!;

    public virtual ICollection<StavkeRezervacije> StavkeRezervacijes { get; set; } = new List<StavkeRezervacije>();
}
