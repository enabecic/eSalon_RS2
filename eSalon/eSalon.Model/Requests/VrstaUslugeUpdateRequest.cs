using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.Requests
{
    public class VrstaUslugeUpdateRequest
    {
        public string Naziv { get; set; } = null!;

        public byte[]? Slika { get; set; }
    }
}
