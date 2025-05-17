using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class Promocija
{
    public int PromocijaId { get; set; }

    public string Naziv { get; set; } = null!;

    public string? Opis { get; set; }

    public string Kod { get; set; } = null!;

    public decimal Popust { get; set; }

    public DateTime DatumPocetka { get; set; }

    public DateTime DatumKraja { get; set; }

    public int UslugaId { get; set; }

    public bool? Status { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual ICollection<AktiviranaPromocija> AktiviranaPromocijas { get; set; } = new List<AktiviranaPromocija>();

    public virtual Usluga Usluga { get; set; } = null!;
}
