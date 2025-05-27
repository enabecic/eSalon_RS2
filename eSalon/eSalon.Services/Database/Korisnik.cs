using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class Korisnik : ISoftDelete
{
    public int KorisnikId { get; set; }

    public string Ime { get; set; } = null!;

    public string Prezime { get; set; } = null!;

    public string KorisnickoIme { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string? Telefon { get; set; }

    public byte[]? Slika { get; set; }

    public string LozinkaHash { get; set; } = null!;

    public string LozinkaSalt { get; set; } = null!;

    public bool? JeAktivan { get; set; }

    public DateTime DatumRegistracije { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual ICollection<AktiviranaPromocija> AktiviranaPromocijas { get; set; } = new List<AktiviranaPromocija>();

    public virtual ICollection<Arhiva> Arhivas { get; set; } = new List<Arhiva>();

    public virtual ICollection<Favorit> Favorits { get; set; } = new List<Favorit>();

    public virtual ICollection<KorisniciUloge> KorisniciUloges { get; set; } = new List<KorisniciUloge>();

    public virtual ICollection<Obavijest> Obavijests { get; set; } = new List<Obavijest>();

    public virtual ICollection<Ocjena> Ocjenas { get; set; } = new List<Ocjena>();

    public virtual ICollection<RecenzijaOdgovorReakcija> RecenzijaOdgovorReakcijas { get; set; } = new List<RecenzijaOdgovorReakcija>();

    public virtual ICollection<RecenzijaOdgovor> RecenzijaOdgovors { get; set; } = new List<RecenzijaOdgovor>();

    public virtual ICollection<RecenzijaReakcija> RecenzijaReakcijas { get; set; } = new List<RecenzijaReakcija>();

    public virtual ICollection<Recenzija> Recenzijas { get; set; } = new List<Recenzija>();

    public virtual ICollection<Rezervacija> RezervacijaFrizers { get; set; } = new List<Rezervacija>();

    public virtual ICollection<Rezervacija> RezervacijaKorisniks { get; set; } = new List<Rezervacija>();
}
