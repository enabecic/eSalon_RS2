using System;
using System.Collections.Generic;

namespace eSalon.Services.Database;

public partial class NacinPlacanja
{
    public int NacinPlacanjaId { get; set; }

    public string Naziv { get; set; } = null!;

    public bool IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public virtual ICollection<Rezervacija> Rezervacijas { get; set; } = new List<Rezervacija>();
}
