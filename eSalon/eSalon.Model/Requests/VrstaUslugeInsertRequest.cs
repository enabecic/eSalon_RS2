using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.Requests
{
    public class VrstaUslugeInsertRequest
    {
        public string Naziv { get; set; } = null!;

        public byte[]? Slika { get; set; }
    }
}
