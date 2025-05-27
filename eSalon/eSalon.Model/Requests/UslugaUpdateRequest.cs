using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eSalon.Model.Requests
{
    public class UslugaUpdateRequest
    {
        [Required(ErrorMessage = "Naziv je obavezan.")]
        [MaxLength(100, ErrorMessage = "Naziv može imati najviše 100 karaktera.")]
        [MinLength(1, ErrorMessage = "Naziv ne može biti prazan.")]
        public string Naziv { get; set; } = string.Empty;

        [Required(ErrorMessage = "Opis je obavezan.")]
        [MaxLength(1000, ErrorMessage = "Opis može imati najviše 1000 karaktera.")]
        [MinLength(1, ErrorMessage = "Opis ne može biti prazan.")]
        public string Opis { get; set; } = string.Empty;

        [Required(ErrorMessage = "Cijena je obavezna.")]
        [Range(1, 1000, ErrorMessage = "Cijena mora biti između 1 i 1000.")]
        public decimal Cijena { get; set; }

        [Required(ErrorMessage = "Trajanje je obavezno.")]
        [Range(10, 300, ErrorMessage = "Trajanje mora biti između 10 i 300.")]
        public int Trajanje { get; set; }

        public byte[]? Slika { get; set; }

        [Required(ErrorMessage = "Vrsta usluge je obavezna.")]
        public int VrstaId { get; set; }
    }
}
