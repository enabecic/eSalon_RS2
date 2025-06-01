using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eSalon.Model.Requests
{
    public class AktiviranaPromocijaInsertRequest
    {
        [Required(ErrorMessage = "Promocija je obavezna.")]
        public int PromocijaId { get; set; }

        [Required(ErrorMessage = "Korisnik je obavezan.")]
        public int KorisnikId { get; set; }
    }
}
