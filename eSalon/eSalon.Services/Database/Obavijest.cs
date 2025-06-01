using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class Obavijest : ISoftDelete
{
    public int ObavijestId { get; set; }

    public int KorisnikId { get; set; }

    public string Naslov { get; set; } = null!;

    public string Sadrzaj { get; set; } = null!;

    public DateTime DatumObavijesti { get; set; }

    public bool JePogledana { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;
}
