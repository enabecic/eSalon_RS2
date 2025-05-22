using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class Usluga : ISoftDelete
{
    public int UslugaId { get; set; }

    public string Naziv { get; set; } = null!;

    public string Opis { get; set; } = null!;

    public decimal Cijena { get; set; }

    public int Trajanje { get; set; }

    public byte[]? Slika { get; set; }

    public DateTime DatumObjavljivanja { get; set; }

    public int VrstaId { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual ICollection<Arhiva> Arhivas { get; set; } = new List<Arhiva>();

    public virtual ICollection<Favorit> Favorits { get; set; } = new List<Favorit>();

    public virtual ICollection<Ocjena> Ocjenas { get; set; } = new List<Ocjena>();

    public virtual ICollection<Promocija> Promocijas { get; set; } = new List<Promocija>();

    public virtual ICollection<Recenzija> Recenzijas { get; set; } = new List<Recenzija>();

    public virtual ICollection<StavkeRezervacije> StavkeRezervacijes { get; set; } = new List<StavkeRezervacije>();

    public virtual VrstaUsluge Vrsta { get; set; } = null!;
}
