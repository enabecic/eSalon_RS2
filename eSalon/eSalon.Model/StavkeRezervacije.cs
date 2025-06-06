using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model
{
    public class StavkeRezervacije
    {
        public int StavkeRezervacijeId { get; set; }

        public int UslugaId { get; set; }

        public int RezervacijaId { get; set; }

        public decimal? Cijena { get; set; }
        public  string ? UslugaNaziv {  get; set; }
        public int ?  Trajanje {  get; set; }

        public decimal? OriginalnaCijena { get; set; } 
        public bool ImaPopust => OriginalnaCijena > Cijena;

        public byte[]? Slika {  get; set; }

    }
}
