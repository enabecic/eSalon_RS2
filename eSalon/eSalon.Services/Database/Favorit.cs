using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class Favorit : ISoftDelete
{
    public int FavoritId { get; set; }

    public int KorisnikId { get; set; }

    public int UslugaId { get; set; }

    public DateTime DatumDodavanja { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;

    public virtual Usluga Usluga { get; set; } = null!;
}
