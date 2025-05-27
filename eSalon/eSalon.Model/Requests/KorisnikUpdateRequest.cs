using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eSalon.Model.Requests
{
    public class KorisnikUpdateRequest
    {
        [Required(ErrorMessage = "Ime je obavezno.")]
        [MaxLength(50, ErrorMessage = "Ime može imati najviše 50 karaktera.")]
        public string Ime { get; set; } = string.Empty;

        [Required(ErrorMessage = "Prezime je obavezno.")]
        [MaxLength(50, ErrorMessage = "Prezime može imati najviše 50 karaktera.")]
        public string Prezime { get; set; } = string.Empty;

        [MaxLength(100, ErrorMessage = "Email može imati najviše 100 karaktera.")]
        [EmailAddress(ErrorMessage = "Email nije u validnom formatu.")]
        public string? Email { get; set; }

        [MaxLength(20, ErrorMessage = "Telefon može imati najviše 20 karaktera.")]
        [Phone(ErrorMessage = "Telefon nije u validnom formatu.")]
        public string? Telefon { get; set; }

        public bool? JeAktivan { get; set; }

        [MinLength(6, ErrorMessage = "Lozinka mora imati najmanje 6 karaktera.")]
        public string? Lozinka { get; set; }

        public string? LozinkaPotvrda { get; set; }

        public string? StaraLozinka { get; set; }
        public byte[]? Slika { get; set; }
    }
}
