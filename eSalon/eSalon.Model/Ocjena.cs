using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model
{
    public class Ocjena
    {
        public int OcjenaId { get; set; }

        public int UslugaId { get; set; }

        public int KorisnikId { get; set; }

        public int Vrijednost { get; set; }

        public DateTime DatumOcjenjivanja { get; set; }
    }
}
