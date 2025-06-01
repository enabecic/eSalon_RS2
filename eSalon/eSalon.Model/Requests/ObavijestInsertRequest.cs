using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model.Requests
{
    public class ObavijestInsertRequest
    {
        public int KorisnikId { get; set; }
        public string Naslov { get; set; } = null!;
        public string Sadrzaj { get; set; } = null!;
    }
}
