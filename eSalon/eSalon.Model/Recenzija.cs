using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model
{
    public class Recenzija
    {
        public int RecenzijaId { get; set; }

        public int KorisnikId { get; set; }

        public int UslugaId { get; set; }

        public string Komentar { get; set; } = null!;

        public DateTime DatumDodavanja { get; set; }

        public int BrojLajkova { get; set; }

        public int BrojDislajkova { get; set; }

        public string? KorisnickoIme { get; set; }
        public string? NazivUsluge { get; set; }
        public int BrojOdgovora { get; set; }
        public bool JeLajkOdKorisnika { get; set; } = false;
        public bool JeDislajkOdKorisnika { get; set; } = false;

    }
}
