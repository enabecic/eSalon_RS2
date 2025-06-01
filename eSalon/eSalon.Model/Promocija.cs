using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model
{
    public class Promocija
    {
        public int PromocijaId { get; set; }
        public string Naziv { get; set; } = null!;
        public string? Opis { get; set; }
        public string Kod { get; set; } = null!;
        public decimal Popust { get; set; }
        public DateTime DatumPocetka { get; set; }
        public DateTime DatumKraja { get; set; }
        public int UslugaId { get; set; }
        public string UslugaNaziv { get; set; } = string.Empty;
        public byte[]? SlikaUsluge { get; set; }
        public bool? Status { get; set; }
    }
}
