using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eSalon.Model.Requests
{
    public class RecenzijaInsertRequest
    {
        [Required(ErrorMessage = "Korisnik je obavezan.")]
        public int KorisnikId { get; set; }

        [Required(ErrorMessage = "Usluga je obavezna.")]
        public int UslugaId { get; set; }

        [Required(ErrorMessage = "Komentar je obavezan.")]
        [MinLength(1, ErrorMessage = "Komentar ne može biti prazan.")]
        [MaxLength(500, ErrorMessage = "Komentar može imati najviše 500 znakova.")]
        public string Komentar { get; set; } = string.Empty;
    }
}
