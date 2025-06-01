using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eSalon.Model.Requests
{
    public class FavoritInsertRequest
    {
        [Required(ErrorMessage = "Korisnik je obavezan.")]
        public int KorisnikId { get; set; }

        [Required(ErrorMessage = "Usluga je obavezna.")]
        public int UslugaId { get; set; }
    }
}
