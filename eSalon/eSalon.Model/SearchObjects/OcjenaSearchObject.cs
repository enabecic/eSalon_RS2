using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.SearchObjects
{
    public class OcjenaSearchObject : BaseSearchObject
    {
        public int? VrijednostGTE { get; set; }
        public int? VrijednostLTE { get; set; }

        public DateTime? DatumOcjenjivanjaGTE { get; set; }
        public DateTime? DatumOcjenjivanjaLTE { get; set; }

        public int? KorisnikId { get; set; }
        public int? UslugaId { get; set; }
    }
}
