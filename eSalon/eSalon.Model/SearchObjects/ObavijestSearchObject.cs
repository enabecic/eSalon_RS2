using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.SearchObjects
{
    public class ObavijestSearchObject : BaseSearchObject
    {
        public int? KorisnikId { get; set; }
        public string? Naslov { get; set; }
        public DateTime? DatumObavijestiGTE { get; set; }
        public DateTime? DatumObavijestiLTE { get; set; }
        public bool? JePogledana { get; set; }
    }
}
