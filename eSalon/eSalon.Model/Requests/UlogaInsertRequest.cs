using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.Requests
{
    public class UlogaInsertRequest
    {
        public string Naziv { get; set; } = null!;

        public string? Opis { get; set; }
    }
}
