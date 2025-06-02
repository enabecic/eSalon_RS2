using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.SearchObjects
{
    public class RecenzijaSearchObject : BaseSearchObject
    {
        public int? KorisnikId { get; set; }
        public int? UslugaId { get; set; }

        public DateTime? DatumDodavanjaGTE { get; set; }
        public DateTime? DatumDodavanjaLTE { get; set; }

        public int? BrojLajkovaGTE { get; set; }
        public int? BrojLajkovaLTE { get; set; }

        public int? BrojDislajkovaGTE { get; set; }
        public int? BrojDislajkovaLTE { get; set; }
    }
}
