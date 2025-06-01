using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model
{
    public class Arhiva
    {
        public int ArhivaId { get; set; }

        public int KorisnikId { get; set; }

        public int UslugaId { get; set; }

        public DateTime DatumDodavanja { get; set; }

        public string? UslugaNaziv { get; set; }

        public decimal? Cijena { get; set; }

        public byte[]? Slika { get; set; }

        public int? Trajanje { get; set; }
    }
}
