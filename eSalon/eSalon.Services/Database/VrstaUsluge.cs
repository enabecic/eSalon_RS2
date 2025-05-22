using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class VrstaUsluge:ISoftDelete
{
    public int VrstaId { get; set; }

    public string Naziv { get; set; } = null!;

    public byte[]? Slika { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual ICollection<Usluga> Uslugas { get; set; } = new List<Usluga>();
}
