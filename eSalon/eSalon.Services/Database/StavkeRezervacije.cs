using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class StavkeRezervacije
{
    public int StavkeRezervacijeId { get; set; }

    public int UslugaId { get; set; }

    public int RezervacijaId { get; set; }

    public decimal? Cijena { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual Rezervacija Rezervacija { get; set; } = null!;

    public virtual Usluga Usluga { get; set; } = null!;
}
