using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.SearchObjects
{
    public class StavkeRezervacijeSearchObject : BaseSearchObject
    {
        public decimal? CijenaLTE { get; set; }
        public decimal? CijenaGTE { get; set; }

        public int? RezervacijaId { get; set; }

        public int? UslugaId { get; set; }
    }
}
