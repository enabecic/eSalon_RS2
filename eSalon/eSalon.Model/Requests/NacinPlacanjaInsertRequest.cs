using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eSalon.Model.Requests
{
    public class NacinPlacanjaInsertRequest
    {
        [Required(ErrorMessage = "Naziv je obavezan.")]
        [MaxLength(50, ErrorMessage = "Naziv može imati najviše 50 karaktera.")]
        [MinLength(1, ErrorMessage = "Naziv ne može biti prazan.")]
        public string Naziv { get; set; } = string.Empty;
    }
}
