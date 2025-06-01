using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.SearchObjects
{
    public class PromocijaSearchObject : BaseSearchObject
    {
        public string? NazivOpisFTS { get; set; }
        public decimal? PopustGTE { get; set; }
        public decimal? PopustLTE { get; set; }
        public int? UslugaId { get; set; }
        public bool? SamoAktivne { get; set; }
        public bool? SamoBuduce { get; set; }
        public bool? SamoProsle { get; set; }
    }
}
