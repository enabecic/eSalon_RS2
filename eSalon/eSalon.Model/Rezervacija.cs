using System;
using System.Collections.Generic;
using System.Text;

namespace eSalon.Model
{
    public class Rezervacija
    {
        public int RezervacijaId { get; set; }

        public int KorisnikId { get; set; }

        public int FrizerId { get; set; }

        public string Sifra { get; set; } = null!;

        public DateTime DatumRezervacije { get; set; }

        public TimeSpan VrijemePocetka { get; set; }

        public TimeSpan? VrijemeKraja { get; set; }
        public bool TerminZatvoren { get; set; }

        public decimal UkupnaCijena { get; set; }

        public int? UkupnoTrajanje { get; set; }

        public int? UkupanBrojUsluga { get; set; }

        public string? StateMachine { get; set; }

        public int NacinPlacanjaId { get; set; }

        public int? AktiviranaPromocijaId { get; set; }

        public string? FrizerImePrezime { get; set; }
        public string? KlijentImePrezime { get; set; }

        public string? NacinPlacanjaNaziv { get; set; }
        public  List<StavkeRezervacije> StavkeRezervacijes { get; set; } = new List<StavkeRezervacije>(); 
    }
}
