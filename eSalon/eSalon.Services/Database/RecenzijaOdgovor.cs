using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class RecenzijaOdgovor
{
    public int RecenzijaOdgovorId { get; set; }

    public int RecenzijaId { get; set; }

    public int KorisnikId { get; set; }

    public string Komentar { get; set; } = null!;

    public DateTime DatumDodavanja { get; set; }

    public int BrojLajkova { get; set; }

    public int BrojDislajkova { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;

    public virtual Recenzija Recenzija { get; set; } = null!;

    public virtual ICollection<RecenzijaOdgovorReakcija> RecenzijaOdgovorReakcijas { get; set; } = new List<RecenzijaOdgovorReakcija>();
}
