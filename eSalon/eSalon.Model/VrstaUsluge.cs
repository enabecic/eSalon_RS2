using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model
{
    public class VrstaUsluge
    {
        public int VrstaId { get; set; }

        public string Naziv { get; set; } = null!;

        public byte[]? Slika { get; set; }
    }
}
