using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eSalon.Model.Requests
{
    public class RezervacijaInsertRequest
    {
        [Required(ErrorMessage = "Korisnik je obavezan.")]
        public int KorisnikId { get; set; }
        [Required(ErrorMessage = "Frizer je obavezan.")]
        public int FrizerId { get; set; }
        [Required(ErrorMessage = "Datum rezervacije je obavezan.")]
        public DateTime DatumRezervacije { get; set; }
        [Required(ErrorMessage = "Vrijeme početka je obavezno.")]
        public TimeSpan VrijemePocetka { get; set; }
        public int? NacinPlacanjaId { get; set; }
        public string? KodPromocije { get; set; }
        public List<StavkeRezervacijeInsertRequest> StavkeRezervacije { get; set; } = new List<StavkeRezervacijeInsertRequest>();
    }
}
