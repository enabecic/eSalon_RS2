using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.Requests
{
    public class UslugaInsertRequest
    {

        public string Naziv { get; set; } = null!;

        public string Opis { get; set; } = null!;

        public decimal Cijena { get; set; }

        public int Trajanje { get; set; }

        public byte[]? Slika { get; set; }

        public int VrstaId { get; set; }
    }
}
