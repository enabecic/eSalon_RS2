using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class RecenzijaOdgovorReakcija
{
    public int RecenzijaOdgovorReakcijaId { get; set; }

    public int RecenzijaOdgovorId { get; set; }

    public int KorisnikId { get; set; }

    public bool JeLajk { get; set; }

    public DateTime DatumReakcije { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;

    public virtual RecenzijaOdgovor RecenzijaOdgovor { get; set; } = null!;
}
