using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.SearchObjects
{
    public class KorisnikSearchObject : BaseSearchObject
    {
        public string? ImePrezime { get; set; }
        public string? Email { get; set; }
        public string? KorisnickoIme { get; set; }
        public string? Telefon { get; set; }
        public int? UlogaId { get; set; }
        public bool? JeAktivan { get; set; }
    }
}
