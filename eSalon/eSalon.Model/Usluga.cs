using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model
{
    public class Usluga
    {
        public int UslugaId { get; set; }

        public string Naziv { get; set; } = null!;

        public string Opis { get; set; } = null!;

        public decimal Cijena { get; set; }

        public int Trajanje { get; set; }

        public byte[]? Slika { get; set; }

        public DateTime DatumObjavljivanja { get; set; }

        public int VrstaId { get; set; }
        public string VrstaUslugeNaziv { get; set; }=string.Empty;
    }
}
