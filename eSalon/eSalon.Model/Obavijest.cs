using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model
{
    public class Obavijest
    {
        public int ObavijestId { get; set; }

        public int KorisnikId { get; set; }

        public string Naslov { get; set; } = null!;

        public string Sadrzaj { get; set; } = null!;

        public DateTime DatumObavijesti { get; set; }

        public bool JePogledana { get; set; }

        public string? ImePrezime { get; set; }
    }
}
