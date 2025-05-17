using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class RecenzijaReakcija
{
    public int RecenzijaReakcijaId { get; set; }

    public int RecenzijaId { get; set; }

    public int KorisnikId { get; set; }

    public bool JeLajk { get; set; }

    public DateTime DatumReakcije { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;

    public virtual Recenzija Recenzija { get; set; } = null!;
}
