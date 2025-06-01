using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.SearchObjects
{
    public class FavoritSearchObject : BaseSearchObject
    {
        public int? KorisnikId { get; set; }
        public int? UslugaId { get; set; }
        public DateTime? DatumDodavanjaGTE { get; set; }
        public DateTime? DatumDodavanjaLTE { get; set; }
    }
}
