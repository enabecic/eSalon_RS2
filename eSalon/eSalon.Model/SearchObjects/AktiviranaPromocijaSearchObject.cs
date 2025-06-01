using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.SearchObjects
{
    public class AktiviranaPromocijaSearchObject : BaseSearchObject
    {
        public int? KorisnikId { get; set; }
        public int? PromocijaId { get; set; }
        public bool? Aktivirana { get; set; }
        public bool? Iskoristena { get; set; }
    }
}
