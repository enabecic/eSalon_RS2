using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.SearchObjects
{
    public class RecenzijaOdgovorSearchObject : BaseSearchObject
    {
        public int? RecenzijaId { get; set; }
        public int? KorisnikId { get; set; }

        public DateTime? DatumDodavanjaGTE { get; set; }
        public DateTime? DatumDodavanjaLTE { get; set; }

        public int? BrojLajkovaGTE { get; set; }
        public int? BrojLajkovaLTE { get; set; }

        public int? BrojDislajkovaGTE { get; set; }
        public int? BrojDislajkovaLTE { get; set; }
        public string? KorisnickoIme { get; set; }
    }
}
