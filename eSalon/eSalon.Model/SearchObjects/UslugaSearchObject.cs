using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.SearchObjects
{
    public class UslugaSearchObject : BaseSearchObject
    {
        public string? NazivOpisFTS { get; set; }

        public int? TrajanjeGTE { get; set; }
        public int? TrajanjeLTE { get; set; }

        public decimal? CijenaGTE { get; set; }
        public decimal? CijenaLTE { get; set; }

        public int? VrstaId { get; set; }
        public int? BrojZadnjeDodanih { get; set; }
    }
}
