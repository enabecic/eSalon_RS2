using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model
{
    public class AktiviranaPromocija
    {
        public int AktiviranaPromocijaId { get; set; }

        public int PromocijaId { get; set; }

        public int KorisnikId { get; set; }

        public bool Aktivirana { get; set; }

        public bool Iskoristena { get; set; }

        public DateTime DatumAktiviranja { get; set; }
        public string PromocijaNaziv { get; set; } = string.Empty;
        public string KorisnikImePrezime { get; set; } = string.Empty;

        public string? KodPromocije { get; set; }
        public byte[]? SlikaUsluge { get; set; }

        public decimal? Popust { get; set; }

        public DateTime? DatumPocetka { get; set; }

        public DateTime? DatumKraja { get; set; }

    }
}
