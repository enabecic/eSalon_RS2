using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eSalon.Model.Requests
{
    public class PromocijaUpdateRequest
    {
        [Required(ErrorMessage = "Naziv je obavezan.")]
        [MaxLength(100, ErrorMessage = "Naziv može imati najviše 100 karaktera.")]
        [MinLength(1, ErrorMessage = "Naziv ne može biti prazan.")]
        public string Naziv { get; set; } = null!;

        [MaxLength(200, ErrorMessage = "Opis može imati najviše 200 karaktera.")]
        public string? Opis { get; set; }

        [Required(ErrorMessage = "Popust je obavezan.")]
        [Range(0.01, 100.0, ErrorMessage = "Popust mora biti između 0.01% i 100%.")]
        public decimal Popust { get; set; }

        [Required(ErrorMessage = "Datum početka je obavezan.")]
        public DateTime DatumPocetka { get; set; }

        [Required(ErrorMessage = "Datum kraja je obavezan.")]
        public DateTime DatumKraja { get; set; }

        [Required(ErrorMessage = "Usluga je obavezna.")]
        public int UslugaId { get; set; }

    }
}
