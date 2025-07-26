using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model
{
    public class RecenzijaOdgovor
    {
        public int RecenzijaOdgovorId { get; set; }

        public int RecenzijaId { get; set; }

        public int KorisnikId { get; set; }

        public string Komentar { get; set; } = null!;

        public DateTime DatumDodavanja { get; set; }

        public int BrojLajkova { get; set; }

        public int BrojDislajkova { get; set; }

        public string? KorisnickoIme { get; set; }
        public string? KomentarRecenzije { get; set; }
    }
}
