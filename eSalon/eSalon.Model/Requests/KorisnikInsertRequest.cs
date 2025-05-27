using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eSalon.Model.Requests
{
    public class KorisnikInsertRequest
    {
        [Required(ErrorMessage = "Ime je obavezno.")]
        [MaxLength(50, ErrorMessage = "Ime može imati najviše 50 karaktera.")]
        public string Ime { get; set; } = string.Empty;

        [Required(ErrorMessage = "Prezime je obavezno.")]
        [MaxLength(50, ErrorMessage = "Prezime može imati najviše 50 karaktera.")]
        public string Prezime { get; set; } = string.Empty;

        [Required(ErrorMessage = "Korisničko ime je obavezno.")]
        [MaxLength(100, ErrorMessage = "Korisničko ime može imati najviše 100 karaktera.")]
        public string KorisnickoIme { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email je obavezan.")]
        [MaxLength(100, ErrorMessage = "Email može imati najviše 100 karaktera.")]
        [EmailAddress(ErrorMessage = "Email nije u ispravnom formatu.")]
        public string Email { get; set; } = string.Empty;

        [MaxLength(20, ErrorMessage = "Telefon može imati najviše 20 karaktera.")]
        [Phone(ErrorMessage = "Telefon nije u ispravnom formatu.")]
        public string? Telefon { get; set; }

        [Required(ErrorMessage = "Lozinka je obavezna.")]
        [MinLength(6, ErrorMessage = "Lozinka mora imati najmanje 6 karaktera.")]
        public string Lozinka { get; set; } = string.Empty;

        [Required(ErrorMessage = "Potvrda lozinke je obavezna.")]
        public string LozinkaPotvrda { get; set; } = string.Empty;

        public List<int> Uloge { get; set; } = new List<int>();
        public byte[]? Slika { get; set; }
    }
}
