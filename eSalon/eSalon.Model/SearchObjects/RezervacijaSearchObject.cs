using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.SearchObjects
{
    public class RezervacijaSearchObject : BaseSearchObject
    {
        public int? KorisnikId { get; set; }

        public int? FrizerId { get; set; }
        public string? Sifra { get; set; }
        public DateTime? DatumRezervacije { get; set; }
        public DateTime? DatumRezervacijeGTE { get; set; }
        public DateTime? DatumRezervacijeLTE { get; set; }
        public List<string>? StateMachine { get; set; }
        public int? NacinPlacanjaId { get; set; }
        public decimal? UkupnaCijena { get; set; }
    }
}
