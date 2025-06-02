using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eSalon.Model.Requests
{
    public class OcjenaUpdateRequest
    {
        [Required(ErrorMessage = "Vrijednost ocjene je obavezna.")]
        [Range(1, 5, ErrorMessage = "Ocjena mora biti između 1 i 5.")]
        public int Vrijednost { get; set; }
    }
}
