using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.SearchObjects
{
    public class ArhivaSearchObject : BaseSearchObject
    {
        public int? KorisnikId { get; set; }
        public int? UslugaId { get; set; }
        public DateTime? DatumDodavanjaGTE { get; set; }
        public DateTime? DatumDodavanjaLTE { get; set; }
    }
}
