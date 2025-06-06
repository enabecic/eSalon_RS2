using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eSalon.Model.Requests
{
    public class StavkeRezervacijeInsertRequest
    {
        [Required(ErrorMessage = "Usluga je obavezana.")]
        public int UslugaId { get; set; }

    }
}
