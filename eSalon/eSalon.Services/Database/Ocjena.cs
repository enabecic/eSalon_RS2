using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class Ocjena
{
    public int OcjenaId { get; set; }

    public int UslugaId { get; set; }

    public int KorisnikId { get; set; }

    public int Vrijednost { get; set; }

    public DateTime DatumOcjenjivanja { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;

    public virtual Usluga Usluga { get; set; } = null!;
}
