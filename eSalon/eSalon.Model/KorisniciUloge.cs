using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model
{
    public class KorisniciUloge
    {
        public int KorisnikUlogaId { get; set; }

        public int KorisnikId { get; set; }

        public int UlogaId { get; set; }

        public bool IsDeleted { get; set; }

        public virtual Uloga Uloga { get; set; } = null!;

    }
}
