using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace eSalon.Services.Database;

public partial class ESalonContext : DbContext
{
    public ESalonContext()
    {
    }

    public ESalonContext(DbContextOptions<ESalonContext> options)
        : base(options)
    {
    }

    public virtual DbSet<AktiviranaPromocija> AktiviranaPromocijas { get; set; }

    public virtual DbSet<Arhiva> Arhivas { get; set; }

    public virtual DbSet<Favorit> Favorits { get; set; }

    public virtual DbSet<KorisniciUloge> KorisniciUloges { get; set; }

    public virtual DbSet<Korisnik> Korisniks { get; set; }

    public virtual DbSet<NacinPlacanja> NacinPlacanjas { get; set; }

    public virtual DbSet<Obavijest> Obavijests { get; set; }

    public virtual DbSet<Ocjena> Ocjenas { get; set; }

    public virtual DbSet<Promocija> Promocijas { get; set; }

    public virtual DbSet<Recenzija> Recenzijas { get; set; }

    public virtual DbSet<RecenzijaOdgovor> RecenzijaOdgovors { get; set; }

    public virtual DbSet<RecenzijaOdgovorReakcija> RecenzijaOdgovorReakcijas { get; set; }

    public virtual DbSet<RecenzijaReakcija> RecenzijaReakcijas { get; set; }

    public virtual DbSet<Rezervacija> Rezervacijas { get; set; }

    public virtual DbSet<StavkeRezervacije> StavkeRezervacijes { get; set; }

    public virtual DbSet<Uloga> Ulogas { get; set; }

    public virtual DbSet<Usluga> Uslugas { get; set; }

    public virtual DbSet<VrstaUsluge> VrstaUsluges { get; set; }

  //  protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
 //#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
 //       => optionsBuilder.UseSqlServer("Data Source=localhost,1433;Initial Catalog=eSalon;user=sa;Password=testmostar;TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AktiviranaPromocija>(entity =>
        {
            entity.HasKey(e => e.AktiviranaPromocijaId).HasName("PK__Aktivira__E44F1952AE21862C");

            entity.ToTable("AktiviranaPromocija");

            entity.Property(e => e.DatumAktiviranja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.PromocijaId).HasColumnName("PromocijaID");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.AktiviranaPromocijas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Aktiviran__Koris__6C190EBB");

            entity.HasOne(d => d.Promocija).WithMany(p => p.AktiviranaPromocijas)
                .HasForeignKey(d => d.PromocijaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Aktiviran__Promo__6B24EA82");
        });

        modelBuilder.Entity<Arhiva>(entity =>
        {
            entity.HasKey(e => e.ArhivaId).HasName("PK__Arhiva__A791E50C258529DA");

            entity.ToTable("Arhiva");

            entity.Property(e => e.DatumDodavanja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Arhivas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Arhiva__Korisnik__5AEE82B9");

            entity.HasOne(d => d.Usluga).WithMany(p => p.Arhivas)
                .HasForeignKey(d => d.UslugaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Arhiva__UslugaId__5BE2A6F2");
        });

        modelBuilder.Entity<Favorit>(entity =>
        {
            entity.HasKey(e => e.FavoritId).HasName("PK__Favorit__C32DB3CCB7D5AA77");

            entity.ToTable("Favorit");

            entity.Property(e => e.DatumDodavanja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Favorits)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Favorit__Korisni__5535A963");

            entity.HasOne(d => d.Usluga).WithMany(p => p.Favorits)
                .HasForeignKey(d => d.UslugaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Favorit__UslugaI__5629CD9C");
        });

        modelBuilder.Entity<KorisniciUloge>(entity =>
        {
            entity.HasKey(e => e.KorisnikUlogaId).HasName("PK__Korisnic__1608726E9F3DF1AD");

            entity.ToTable("KorisniciUloge");

            entity.Property(e => e.DatumDodavanja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.KorisniciUloges)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Korisnici__Koris__412EB0B6");

            entity.HasOne(d => d.Uloga).WithMany(p => p.KorisniciUloges)
                .HasForeignKey(d => d.UlogaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Korisnici__Uloga__4222D4EF");
        });

        modelBuilder.Entity<Korisnik>(entity =>
        {
            entity.HasKey(e => e.KorisnikId).HasName("PK__Korisnik__80B06D41D5A05C3E");

            entity.ToTable("Korisnik");

            entity.HasIndex(e => e.KorisnickoIme, "UQ__Korisnik__992E6F92066ADDE1").IsUnique();

            entity.HasIndex(e => e.Email, "UQ__Korisnik__A9D105345A0525D1").IsUnique();

            entity.Property(e => e.DatumRegistracije)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Email).HasMaxLength(255);
            entity.Property(e => e.Ime).HasMaxLength(100);
            entity.Property(e => e.JeAktivan).HasDefaultValueSql("((1))");
            entity.Property(e => e.KorisnickoIme).HasMaxLength(50);
            entity.Property(e => e.Prezime).HasMaxLength(100);
            entity.Property(e => e.Telefon).HasMaxLength(50);
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");
        });

        modelBuilder.Entity<NacinPlacanja>(entity =>
        {
            entity.HasKey(e => e.NacinPlacanjaId).HasName("PK__NacinPla__AD0C4729CEFE554B");

            entity.ToTable("NacinPlacanja");

            entity.Property(e => e.Naziv).HasMaxLength(100);
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");
        });

        modelBuilder.Entity<Obavijest>(entity =>
        {
            entity.HasKey(e => e.ObavijestId).HasName("PK__Obavijes__99D330E0E1DFA3E0");

            entity.ToTable("Obavijest");

            entity.Property(e => e.DatumObavijesti)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Naslov).HasMaxLength(255);
            entity.Property(e => e.Sadrzaj).HasColumnType("text");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Obavijests)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Obavijest__Koris__4F7CD00D");
        });

        modelBuilder.Entity<Ocjena>(entity =>
        {
            entity.HasKey(e => e.OcjenaId).HasName("PK__Ocjena__E6FC7AA94668F7DF");

            entity.ToTable("Ocjena");

            entity.Property(e => e.DatumOcjenjivanja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Ocjenas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Ocjena__Korisnik__02084FDA");

            entity.HasOne(d => d.Usluga).WithMany(p => p.Ocjenas)
                .HasForeignKey(d => d.UslugaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Ocjena__UslugaId__01142BA1");
        });

        modelBuilder.Entity<Promocija>(entity =>
        {
            entity.HasKey(e => e.PromocijaId).HasName("PK__Promocij__2C5ACD714D0FD88B");

            entity.ToTable("Promocija");

            entity.Property(e => e.PromocijaId).HasColumnName("PromocijaID");
            entity.Property(e => e.DatumKraja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DatumPocetka)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Kod).HasMaxLength(150);
            entity.Property(e => e.Naziv).HasMaxLength(255);
            entity.Property(e => e.Opis).HasColumnType("text");
            entity.Property(e => e.Popust).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.Status)
                .IsRequired()
                .HasDefaultValueSql("((1))");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Usluga).WithMany(p => p.Promocijas)
                .HasForeignKey(d => d.UslugaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Promocija__Uslug__66603565");
        });

        modelBuilder.Entity<Recenzija>(entity =>
        {
            entity.HasKey(e => e.RecenzijaId).HasName("PK__Recenzij__D36C60705E30AA70");

            entity.ToTable("Recenzija");

            entity.Property(e => e.BrojDislajkova).HasDefaultValueSql("((0))");
            entity.Property(e => e.BrojLajkova).HasDefaultValueSql("((0))");
            entity.Property(e => e.DatumDodavanja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Komentar).HasColumnType("text");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Recenzijas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Recenzija__Koris__07C12930");

            entity.HasOne(d => d.Usluga).WithMany(p => p.Recenzijas)
                .HasForeignKey(d => d.UslugaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Recenzija__Uslug__08B54D69");
        });

        modelBuilder.Entity<RecenzijaOdgovor>(entity =>
        {
            entity.HasKey(e => e.RecenzijaOdgovorId).HasName("PK__Recenzij__23922A44E1A14A69");

            entity.ToTable("RecenzijaOdgovor");

            entity.Property(e => e.BrojDislajkova).HasDefaultValueSql("((0))");
            entity.Property(e => e.BrojLajkova).HasDefaultValueSql("((0))");
            entity.Property(e => e.DatumDodavanja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Komentar).HasColumnType("text");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.RecenzijaOdgovors)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Recenzija__Koris__10566F31");

            entity.HasOne(d => d.Recenzija).WithMany(p => p.RecenzijaOdgovors)
                .HasForeignKey(d => d.RecenzijaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Recenzija__Recen__0F624AF8");
        });

        modelBuilder.Entity<RecenzijaOdgovorReakcija>(entity =>
        {
            entity.HasKey(e => e.RecenzijaOdgovorReakcijaId).HasName("PK__Recenzij__BA973BC7765F9E67");

            entity.ToTable("RecenzijaOdgovorReakcija");

           // entity.Property(e => e.RecenzijaOdgovorReakcijaId).ValueGeneratedNever();
            entity.Property(e => e.DatumReakcije).HasColumnType("datetime");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.RecenzijaOdgovorReakcijas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Recenzija__Koris__1CBC4616");

            entity.HasOne(d => d.RecenzijaOdgovor).WithMany(p => p.RecenzijaOdgovorReakcijas)
                .HasForeignKey(d => d.RecenzijaOdgovorId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Recenzija__Recen__1BC821DD");
        });

        modelBuilder.Entity<RecenzijaReakcija>(entity =>
        {
            entity.HasKey(e => e.RecenzijaReakcijaId).HasName("PK__Recenzij__7B1C616C559DBD16");

            entity.ToTable("RecenzijaReakcija");

           // entity.Property(e => e.RecenzijaReakcijaId).ValueGeneratedNever();
            entity.Property(e => e.DatumReakcije).HasColumnType("datetime");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.RecenzijaReakcijas)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Recenzija__Koris__17F790F9");

            entity.HasOne(d => d.Recenzija).WithMany(p => p.RecenzijaReakcijas)
                .HasForeignKey(d => d.RecenzijaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Recenzija__Recen__17036CC0");
        });

        modelBuilder.Entity<Rezervacija>(entity =>
        {
            entity.HasKey(e => e.RezervacijaId).HasName("PK__Rezervac__CABA44DD5D0F9C23");

            entity.ToTable("Rezervacija");

            entity.Property(e => e.DatumRezervacije)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("date");
            entity.Property(e => e.Sifra).HasMaxLength(150);
            entity.Property(e => e.StateMachine).HasMaxLength(100);
            entity.Property(e => e.UkupnaCijena).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.AktiviranaPromocija).WithMany(p => p.Rezervacijas)
                .HasForeignKey(d => d.AktiviranaPromocijaId)
                .HasConstraintName("FK__Rezervaci__Aktiv__787EE5A0");

            entity.HasOne(d => d.Frizer).WithMany(p => p.RezervacijaFrizers)
                .HasForeignKey(d => d.FrizerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Rezervaci__Frize__73BA3083");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.RezervacijaKorisniks)
                .HasForeignKey(d => d.KorisnikId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Rezervaci__Koris__72C60C4A");

            entity.HasOne(d => d.NacinPlacanja).WithMany(p => p.Rezervacijas)
                .HasForeignKey(d => d.NacinPlacanjaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Rezervaci__Nacin__778AC167");
        });

        modelBuilder.Entity<StavkeRezervacije>(entity =>
        {
            entity.HasKey(e => e.StavkeRezervacijeId).HasName("PK__StavkeRe__17239E701F07736A");

            entity.ToTable("StavkeRezervacije");

            entity.Property(e => e.Cijena).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Rezervacija).WithMany(p => p.StavkeRezervacijes)
                .HasForeignKey(d => d.RezervacijaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__StavkeRez__Rezer__7D439ABD");

            entity.HasOne(d => d.Usluga).WithMany(p => p.StavkeRezervacijes)
                .HasForeignKey(d => d.UslugaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__StavkeRez__Uslug__7C4F7684");
        });

        modelBuilder.Entity<Uloga>(entity =>
        {
            entity.HasKey(e => e.UlogaId).HasName("PK__Uloga__DCAB23CB8D8DBCEC");

            entity.ToTable("Uloga");

            entity.Property(e => e.Naziv).HasMaxLength(50);
            entity.Property(e => e.Opis).HasMaxLength(255);
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");
        });

        modelBuilder.Entity<Usluga>(entity =>
        {
            entity.HasKey(e => e.UslugaId).HasName("PK__Usluga__0BE5E72F255F7E85");

            entity.ToTable("Usluga");

            entity.Property(e => e.Cijena).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.DatumObjavljivanja)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Naziv).HasMaxLength(255);
            entity.Property(e => e.Opis).HasColumnType("text");
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");

            entity.HasOne(d => d.Vrsta).WithMany(p => p.Uslugas)
                .HasForeignKey(d => d.VrstaId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Usluga__VrstaId__4BAC3F29");
        });

        modelBuilder.Entity<VrstaUsluge>(entity =>
        {
            entity.HasKey(e => e.VrstaId).HasName("PK__VrstaUsl__42CB8F2F695BF2C1");

            entity.ToTable("VrstaUsluge");

            entity.Property(e => e.Naziv).HasMaxLength(100);
            entity.Property(e => e.VrijemeBrisanja).HasColumnType("datetime");
        });

        try
        {
            Console.WriteLine("Seed podataka");
            modelBuilder.Seed();
        }
        catch (Exception ex)
        {
            Console.WriteLine("Greška prilikom seedanja:");
            Console.WriteLine(ex.ToString());
        }

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}

public static class ModelBuilderExtensions
{
    public static void Seed(this ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Uloga>().HasData(
            new Uloga { UlogaId = 1, Naziv = "Admin", Opis = "Administrator sistema", IsDeleted = false, VrijemeBrisanja = null },
            new Uloga { UlogaId = 2, Naziv = "Frizer", Opis = "Frizer u salonu", IsDeleted = false, VrijemeBrisanja = null },
            new Uloga { UlogaId = 3, Naziv = "Klijent", Opis = "Klijent u salonu", IsDeleted = false, VrijemeBrisanja = null }
        );

        modelBuilder.Entity<NacinPlacanja>().HasData(
            new NacinPlacanja { NacinPlacanjaId = 1, Naziv = "Gotovina", IsDeleted = false, VrijemeBrisanja = null },
            new NacinPlacanja { NacinPlacanjaId = 2, Naziv = "PayPal", IsDeleted = false, VrijemeBrisanja = null }
        );

        modelBuilder.Entity<VrstaUsluge>().HasData(
            new VrstaUsluge { VrstaId = 1, Naziv = "Šišanje kose", Slika = null, IsDeleted = false, VrijemeBrisanja = null },
            new VrstaUsluge { VrstaId = 2, Naziv = "Farbanje kose", Slika = null, IsDeleted = false, VrijemeBrisanja = null },
            new VrstaUsluge { VrstaId = 3, Naziv = "Tretmani kose", Slika = null, IsDeleted = false, VrijemeBrisanja = null },
            new VrstaUsluge { VrstaId = 4, Naziv = "Frizure / Styling", Slika = null, IsDeleted = false, VrijemeBrisanja = null },
            new VrstaUsluge { VrstaId = 5, Naziv = "Muško šišanje i briga o bradi", Slika = null, IsDeleted = false, VrijemeBrisanja = null },
            new VrstaUsluge { VrstaId = 6, Naziv = "Pranje i priprema kose", Slika = null, IsDeleted = false, VrijemeBrisanja = null }
        );

        modelBuilder.Entity<Usluga>().HasData(
            new Usluga
            {
                UslugaId = 1,
                Naziv = "Šišanje kratke kose",
                Opis = "Šišanje kratke kose uz precizno oblikovanje koje naglašava prirodne crte lica i daje uredan i moderan izgled.",
                Cijena = 20,
                Trajanje = 30,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 2, 10, 0, 0, 0),
                VrstaId = 1,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 2,
                Naziv = "Šišanje duge kose",
                Opis = "Šišanje duge kose uz precizno oblikovanje koje olakšava stiliziranje i održavanje zdrave kose.",
                Cijena = 25,
                Trajanje = 50,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 2, 10, 0, 0, 0),
                VrstaId = 1,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 3,
                Naziv = "Dječije šišanje",
                Opis = "Precizno i sigurno šišanje kose kod djece uz fokus na udobnost i kvalitetan rezultat.",
                Cijena = 15,
                Trajanje = 30,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 2, 10, 0, 0, 0),
                VrstaId = 1,
                IsDeleted = false,
                VrijemeBrisanja = null
            },

           
            new Usluga
            {
                UslugaId = 4,
                Naziv = "Klasično farbanje kose",
                Opis = "Farbanje cijele kose u željenu nijansu uz preciznu primjenu boje. Ovo farbanje osigurava dugotrajan rezultat i ravnomjernu boju. Idealno za promjenu stila ili osvježavanje postojećeg tona kose.",
                Cijena = 40,
                Trajanje = 60,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 2, 10, 0, 0, 0),
                VrstaId = 2,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 5,
                Naziv = "Balayage",
                Opis = "Tehnika prirodnog prelijevanja nijansi koja daje efekt dubine i svjetlosti u kosi. Prikladno za sve tipove kose i različite dužine, a rezultat je prirodan i sofisticiran.",
                Cijena = 70,
                Trajanje = 90,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 10, 10, 0, 0, 0),
                VrstaId = 2,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 6,
                Naziv = "Pramenovi",
                Opis = "Dodavanje svijetlijih ili tamnijih pramenova po želji klijenta za efekt dubine i teksture u kosi. Pramenovi mogu biti tanki ili široki, ovisno o željenom stilu. Ovaj tretman naglašava volumen kose i stvara moderan izgled prilagođen klijentu.",
                Cijena = 70,
                Trajanje = 75,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 6, 10, 0, 0, 0),
                VrstaId = 2,
                IsDeleted = false,
                VrijemeBrisanja = null
            },


            new Usluga
            {
                UslugaId = 7,
                Naziv = "Regenerativni tretman oštećene kose",
                Opis = "Dubinska obnova oštećene kose. Obnavlja strukturu vlasi, vraća mekoću i sjaj. Pogodno za kosu oštećenu farbanjem ili stiliziranjem. Sprječava pucanje vrhova i poboljšava elastičnost kose.",
                Cijena = 250,
                Trajanje = 60,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 8, 10, 0, 0, 0),
                VrstaId = 3,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 8,
                Naziv = "Tretman protiv opadanja kose",
                Opis = "Tretman za jačanje korijena i smanjenje opadanja kose. Aktivni sastojci stimuliraju vlasište i potiču rast novih vlasi. Ojačava kosu i povećava njenu otpornost na lomljenje i oštećenja. Preporučuje se kod smanjenja gustoće kose i gubitka volumena.",
                Cijena = 250,
                Trajanje = 50,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 9, 10, 0, 0, 0),
                VrstaId = 3,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 9,
                Naziv = "Keratin tretman",
                Opis = "Keratin tretman koji poravnava kosu i smanjuje kovrčanje. Pruža dugotrajan sjaj, glatkoću i olakšava stiliziranje. Obnavlja oštećene vlasi i čini kosu mekšom i lakšom za oblikovanje. Pogodan za sve tipove kose.",
                Cijena = 300,
                Trajanje = 60,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 19, 10, 0, 0, 0),
                VrstaId = 3,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 10,
                Naziv = "Hidratantni tretman kose",
                Opis = "Intenzivna hidratacija za suhu i oštećenu kosu. Dubinski njeguje vlasi, vraća vlagu i elastičnost kose. Pomaže u smanjenju lomljenja i oštećenja uz povećanje sjaja. Preporučuje se kod suhe, ispucale ili hemijski tretirane kose.",
                Cijena = 200,
                Trajanje = 60,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 18, 10, 0, 0, 0),
                VrstaId = 3,
                IsDeleted = false,
                VrijemeBrisanja = null
            },


            new Usluga
            {
                UslugaId = 11,
                Naziv = "Uvijanje kose",
                Opis = "Uvijanje kose za definisane lokne ili blage valove. Može se prilagoditi različitim dužinama i teksturama kose. Idealno za svaki stil i priliku.",
                Cijena = 30,
                Trajanje = 30,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 6, 10, 0, 0, 0),
                VrstaId = 4,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 12,
                Naziv = "Peglanje kose",
                Opis = "Ravnanje kose peglom za glatku i sjajnu kosu. Pruža uredan izgled i olakšava stiliziranje. Pogodno za sve tipove kose.",
                Cijena = 30,
                Trajanje = 30,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 4, 10, 0, 0, 0),
                VrstaId = 4,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 13,
                Naziv = "Frizura – rep",
                Opis = "Stilizovanje kose u rep. Može biti visoki, niski ili srednji rep. Prikladno za svakodnevne ili svečane prilike. Pruža uredan i elegantan izgled koji se dugo održava.",
                Cijena = 20,
                Trajanje = 20,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 4, 10, 0, 0, 0),
                VrstaId = 4,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 14,
                Naziv = "Frizura – punđa",
                Opis = "Stilizovanje kose u punđu. Može biti niska, visoka ili klasična punđa. Pogodno za formalne događaje ili elegantan dnevni izgled. Zadržava oblik dugo i pruža uredan završni dojam.",
                Cijena = 25,
                Trajanje = 30,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 7, 10, 0, 0, 0),
                VrstaId = 4,
                IsDeleted = false,
                VrijemeBrisanja = null
            },

            new Usluga
            {
                UslugaId = 15,
                Naziv = "Ekstenzije i nadogradnja kose",
                Opis = "Profesionalno dodavanje dužine i volumena kose. Omogućava prirodan izgled i dodatni volumen, prilagođeno tipu i strukturi kose. Pogodno za posebne prilike ili svakodnevni stil.",
                Cijena = 250,
                Trajanje = 120,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 20, 10, 0, 0, 0),
                VrstaId = 4,
                IsDeleted = false,
                VrijemeBrisanja = null
            },


            new Usluga
            {
                UslugaId = 16,
                Naziv = "Klasično muško šišanje",
                Opis = "Standardno šišanje za muškarce. Precizno oblikovanje i skraćivanje kose prema želji klijenta. Pruža uredan, profesionalan i moderan izgled. Pogodno za sve tipove kose.",
                Cijena = 15,
                Trajanje = 30,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 2, 10, 0, 0, 0),
                VrstaId = 5,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 17,
                Naziv = "Moderno muško šišanje (FADE)",
                Opis = "Trendy muško šišanje s fade efektom. Obuhvata fade, undercut ili kombinaciju modernih stilova. Omogućava lako stiliziranje i moderan izgled.",
                Cijena = 20,
                Trajanje = 40,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 2, 10, 0, 0, 0),
                VrstaId = 5,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 18,
                Naziv = "Uređivanje brade",
                Opis = "Brijanje, trimanje i oblikovanje brade prema željenom stilu. Pruža uredan i sofisticiran izgled. Pogodno za sve tipove brade.",
                Cijena = 15,
                Trajanje = 20,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 2, 10, 0, 0, 0),
                VrstaId = 5,
                IsDeleted = false,
                VrijemeBrisanja = null
            },


            new Usluga
            {
                UslugaId = 19,
                Naziv = "Standardno pranje kose",
                Opis = "Klasično pranje kose uz nježnu masažu vlasišta. Uključuje nanošenje regeneratora ili maske za dodatnu njegu i hidrataciju. Prikladno za sve tipove kose i pripremu za šišanje ili stiliziranje.",
                Cijena = 15,
                Trajanje = 25,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 2, 10, 0, 0, 0),
                VrstaId = 6,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Usluga
            {
                UslugaId = 20,
                Naziv = "Temeljito pranje kose",
                Opis = "Temeljito pranje kose uz masažu koje uklanja višak masnoće i nečistoće. Pruža osjećaj čiste i osvježene kose te priprema kosu za tretmane ili stiliziranje. Prikladno za sve tipove kose.",
                Cijena = 20,
                Trajanje = 30,
                Slika = null,
                DatumObjavljivanja = new DateTime(2025, 1, 2, 10, 0, 0, 0),
                VrstaId = 6,
                IsDeleted = false,
                VrijemeBrisanja = null
            }
        );

        modelBuilder.Entity<Korisnik>().HasData(
            new Korisnik
            {
                KorisnikId = 1,
                Ime = "Admin",
                Prezime = "Admin",
                KorisnickoIme = "admin",
                Email = "admin@gmail.com",
                Telefon = "+062303101",
                Slika = null,
                LozinkaHash = "3LwfrQwoet7CItpIVOuM0nevxfhNQ5o6fa/sIsZJp4E=",
                LozinkaSalt = "dRwqm+pOWW2BhcWRA5l/pA==",
                JeAktivan = true,
                DatumRegistracije = new DateTime(2025, 1, 1, 10, 0, 0, 0),
                IsDeleted = false,
                VrijemeBrisanja = null
            },

            new Korisnik
            {
                KorisnikId = 2,
                Ime = "Frizer",
                Prezime = "Frizer",
                KorisnickoIme = "frizer",
                Email = "frizer@gmail.com",
                Telefon = "+062303101",
                Slika = null,
                LozinkaHash = "3LwfrQwoet7CItpIVOuM0nevxfhNQ5o6fa/sIsZJp4E=",
                LozinkaSalt = "dRwqm+pOWW2BhcWRA5l/pA==",
                JeAktivan = true,
                DatumRegistracije = new DateTime(2025, 1, 1, 10, 0, 0, 0),
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Korisnik
            {
                KorisnikId = 3,
                Ime = "FrizerDva",
                Prezime = "FrizerDva",
                KorisnickoIme = "frizer2",
                Email = "frizer2@gmail.com",
                Telefon = "+062303101",
                Slika = null,
                LozinkaHash = "3LwfrQwoet7CItpIVOuM0nevxfhNQ5o6fa/sIsZJp4E=",
                LozinkaSalt = "dRwqm+pOWW2BhcWRA5l/pA==",
                JeAktivan = true,
                DatumRegistracije = new DateTime(2025, 1, 1, 10, 0, 0, 0),
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Korisnik
            {
                KorisnikId = 4,
                Ime = "FrizerTri",
                Prezime = "FrizerTri",
                KorisnickoIme = "frizer3",
                Email = "frizer3@gmail.com",
                Telefon = "+062303101",
                Slika = null,
                LozinkaHash = "3LwfrQwoet7CItpIVOuM0nevxfhNQ5o6fa/sIsZJp4E=",
                LozinkaSalt = "dRwqm+pOWW2BhcWRA5l/pA==",
                JeAktivan = true,
                DatumRegistracije = new DateTime(2025, 1, 1, 10, 0, 0, 0),
                IsDeleted = false,
                VrijemeBrisanja = null
            },

            new Korisnik
            {
                KorisnikId = 5,
                Ime = "Klijent",
                Prezime = "Klijent",
                KorisnickoIme = "klijent",
                Email = "klijent@gmail.com",
                Telefon = "+062303101",
                Slika = null,
                LozinkaHash = "3LwfrQwoet7CItpIVOuM0nevxfhNQ5o6fa/sIsZJp4E=",
                LozinkaSalt = "dRwqm+pOWW2BhcWRA5l/pA==",
                JeAktivan = true,
                DatumRegistracije = new DateTime(2025, 1, 1, 10, 0, 0, 0),
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Korisnik
            {
                KorisnikId = 6,
                Ime = "KlijentDva",
                Prezime = "KlijentDva",
                KorisnickoIme = "klijent2",
                Email = "klijent2@gmail.com",
                Telefon = "+062303101",
                Slika = null,
                LozinkaHash = "3LwfrQwoet7CItpIVOuM0nevxfhNQ5o6fa/sIsZJp4E=",
                LozinkaSalt = "dRwqm+pOWW2BhcWRA5l/pA==",
                JeAktivan = true,
                DatumRegistracije = new DateTime(2025, 1, 1, 10, 0, 0, 0),
                IsDeleted = false,
                VrijemeBrisanja = null
            }
        );

        modelBuilder.Entity<KorisniciUloge>().HasData(
  
            new KorisniciUloge
            {
                KorisnikUlogaId = 1,
                KorisnikId = 1,
                UlogaId = 1,
                DatumDodavanja = new DateTime(2025, 1, 1, 10, 0, 0, 0),
                IsDeleted = false,
                VrijemeBrisanja = null
            },

            new KorisniciUloge
            {
                KorisnikUlogaId = 2,
                KorisnikId = 2,
                UlogaId = 2,
                DatumDodavanja = new DateTime(2025, 1, 1, 10, 0, 0, 0),
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new KorisniciUloge
            {
                KorisnikUlogaId = 3,
                KorisnikId = 3,
                UlogaId = 2,
                DatumDodavanja = new DateTime(2025, 1, 1, 10, 0, 0, 0),
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new KorisniciUloge
            {
                KorisnikUlogaId = 4,
                KorisnikId = 4,
                UlogaId = 2,
                DatumDodavanja = new DateTime(2025, 1, 1, 10, 0, 0, 0),
                IsDeleted = false,
                VrijemeBrisanja = null
            },

            new KorisniciUloge
            {
                KorisnikUlogaId = 5,
                KorisnikId = 5,
                UlogaId = 3,
                DatumDodavanja = new DateTime(2025, 1, 1, 10, 0, 0, 0),
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new KorisniciUloge
            {
                KorisnikUlogaId = 6,
                KorisnikId = 6,
                UlogaId = 3,
                DatumDodavanja = new DateTime(2025, 1, 1, 10, 0, 0, 0),
                IsDeleted = false,
                VrijemeBrisanja = null
            }
        );

        modelBuilder.Entity<Favorit>().HasData(
 
            new Favorit { FavoritId = 1, KorisnikId = 5, UslugaId = 1, DatumDodavanja = new DateTime(2026, 1, 3, 10, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 2, KorisnikId = 5, UslugaId = 5, DatumDodavanja = new DateTime(2026, 1, 11, 10, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 3, KorisnikId = 5, UslugaId = 6, DatumDodavanja = new DateTime(2026, 1, 7, 10, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 4, KorisnikId = 5, UslugaId = 8, DatumDodavanja = new DateTime(2026, 1, 10, 10, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 5, KorisnikId = 5, UslugaId = 10, DatumDodavanja = new DateTime(2026, 1, 20, 10, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 6, KorisnikId = 5, UslugaId = 12, DatumDodavanja = new DateTime(2026, 1, 5, 10, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 7, KorisnikId = 5, UslugaId = 15, DatumDodavanja = new DateTime(2026, 1, 21, 10, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },

            new Favorit { FavoritId = 8, KorisnikId = 6, UslugaId = 2, DatumDodavanja = new DateTime(2026, 1, 3, 11, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 9, KorisnikId = 6, UslugaId = 3, DatumDodavanja = new DateTime(2026, 1, 3, 12, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 10, KorisnikId = 6, UslugaId = 4, DatumDodavanja = new DateTime(2026, 1, 3, 13, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 11, KorisnikId = 6, UslugaId = 7, DatumDodavanja = new DateTime(2026, 1, 9, 10, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 12, KorisnikId = 6, UslugaId = 9, DatumDodavanja = new DateTime(2026, 1, 20, 10, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 13, KorisnikId = 6, UslugaId = 11, DatumDodavanja = new DateTime(2026, 1, 7, 10, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 14, KorisnikId = 6, UslugaId = 14, DatumDodavanja = new DateTime(2026, 1, 8, 10, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Favorit { FavoritId = 15, KorisnikId = 6, UslugaId = 16, DatumDodavanja = new DateTime(2026, 1, 3, 14, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null }
        );


        modelBuilder.Entity<Arhiva>().HasData(
            new Arhiva { ArhivaId = 1, KorisnikId = 5, UslugaId = 1, DatumDodavanja = new DateTime(2026, 1, 2, 12, 0, 0, 123), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 2, KorisnikId = 5, UslugaId = 4, DatumDodavanja = new DateTime(2026, 1, 2, 13, 30, 0, 456), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 3, KorisnikId = 5, UslugaId = 6, DatumDodavanja = new DateTime(2026, 1, 6, 11, 15, 0, 789), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 4, KorisnikId = 5, UslugaId = 7, DatumDodavanja = new DateTime(2026, 1, 8, 14, 45, 0, 321), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 5, KorisnikId = 5, UslugaId = 11, DatumDodavanja = new DateTime(2026, 1, 6, 16, 20, 0, 654), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 6, KorisnikId = 5, UslugaId = 14, DatumDodavanja = new DateTime(2026, 1, 7, 10, 10, 0, 987), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 7, KorisnikId = 5, UslugaId = 16, DatumDodavanja = new DateTime(2026, 1, 2, 15, 0, 0, 111), IsDeleted = false, VrijemeBrisanja = null },

            new Arhiva { ArhivaId = 8, KorisnikId = 6, UslugaId = 2, DatumDodavanja = new DateTime(2026, 1, 2, 12, 5, 0, 222), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 9, KorisnikId = 6, UslugaId = 5, DatumDodavanja = new DateTime(2026, 1, 10, 11, 10, 0, 333), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 10, KorisnikId = 6, UslugaId = 8, DatumDodavanja = new DateTime(2026, 1, 9, 14, 25, 0, 444), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 11, KorisnikId = 6, UslugaId = 9, DatumDodavanja = new DateTime(2026, 1, 19, 10, 30, 0, 555), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 12, KorisnikId = 6, UslugaId = 12, DatumDodavanja = new DateTime(2026, 1, 4, 12, 45, 0, 666), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 13, KorisnikId = 6, UslugaId = 13, DatumDodavanja = new DateTime(2026, 1, 4, 13, 0, 0, 777), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 14, KorisnikId = 6, UslugaId = 15, DatumDodavanja = new DateTime(2026, 1, 20, 12, 15, 0, 888), IsDeleted = false, VrijemeBrisanja = null },
            new Arhiva { ArhivaId = 15, KorisnikId = 6, UslugaId = 20, DatumDodavanja = new DateTime(2026, 1, 2, 16, 0, 0, 999), IsDeleted = false, VrijemeBrisanja = null }
        );

        modelBuilder.Entity<Promocija>().HasData(

            new Promocija { PromocijaId = 1, Naziv = "Novogodišnji popust", Opis = "Iskoristite popust za šišanje kratke kose i zablistajte u prazničnom periodu. Naši stručni frizeri pažljivo će oblikovati vašu kosu, naglasiti prirodne crte lica i osigurati uredan, moderan izgled koji će trajati. Savršena prilika da osvježite svoj stil i osjećate se samouvjereno u svakom trenutku.", Kod = "AB12CD", Popust = 20, DatumPocetka = new DateTime(2025, 12, 5, 10, 0, 0, 0), DatumKraja = new DateTime(2025, 12, 20, 23, 59, 0, 0), UslugaId = 1, Status = true, IsDeleted = false, VrijemeBrisanja = null },
            new Promocija { PromocijaId = 2, Naziv = "Ekskluzivni tretman", Opis = "Balayage tretman po sniženoj cijeni za savršen izgled kose pred kraj godine. Naši frizeri pažljivo će nanijeti nijanse koje naglašavaju prirodnu ljepotu vaše kose, dodajući volumen i sjaj za elegantan i sofisticiran završni dojam.", Kod = "EF34GH", Popust = 30, DatumPocetka = new DateTime(2025, 12, 10, 10, 0, 0, 0), DatumKraja = new DateTime(2025, 12, 28, 23, 59, 0, 0), UslugaId = 5, Status = true, IsDeleted = false, VrijemeBrisanja = null },
            new Promocija { PromocijaId = 3, Naziv = "Dječije veselje", Opis = "Sigurno i precizno dječije šišanje po sniženoj cijeni, za zadovoljstvo mališana.", Kod = "IJ56KL", Popust = 15, DatumPocetka = new DateTime(2025, 12, 7, 10, 0, 0, 0), DatumKraja = new DateTime(2025, 12, 22, 23, 59, 0, 0), UslugaId = 3, Status = true, IsDeleted = false, VrijemeBrisanja = null },
            new Promocija { PromocijaId = 4, Naziv = "Savršena boja", Opis = "Klasično farbanje kose po promotivnoj cijeni, za osvježavanje i ujednačen ton kose, dajući joj zdrav i sjajan izgled.", Kod = "MN78OP", Popust = 40, DatumPocetka = new DateTime(2025, 12, 8, 10, 0, 0, 0), DatumKraja = new DateTime(2025, 12, 30, 23, 59, 0, 0), UslugaId = 4, Status = true, IsDeleted = false, VrijemeBrisanja = null },
            new Promocija { PromocijaId = 5, Naziv = "Muški stil", Opis = "Standardno muško šišanje po sniženoj cijeni za elegantan i uredan izgled.", Kod = "QR90ST", Popust = 25, DatumPocetka = new DateTime(2025, 12, 12, 10, 0, 0, 0), DatumKraja = new DateTime(2025, 12, 29, 23, 59, 0, 0), UslugaId = 16, Status = true, IsDeleted = false, VrijemeBrisanja = null },

            new Promocija { PromocijaId = 6, Naziv = "Frizerski popust", Opis = "Iskoristite popust na šišanje duge kose i osvježite svoj stil, uz precizno oblikovanje koje naglašava prirodne crte lica i daje uredan, moderan izgled.", Kod = "UV12WX", Popust = 20, DatumPocetka = new DateTime(2026, 1, 2, 10, 0, 0, 0), DatumKraja = new DateTime(2026, 2, 28, 23, 59, 0, 0), UslugaId = 2, Status = true, IsDeleted = false, VrijemeBrisanja = null },
            new Promocija { PromocijaId = 7, Naziv = "Pramenovi akcija", Opis = "Pramenovi sada po sniženoj cijeni za moderan i voluminozan izgled, uz naglašavanje teksture i svjetlijih tonova koji daju prirodan sjaj i dubinu kose.", Kod = "YZ34AB", Popust = 35, DatumPocetka = new DateTime(2026, 1, 5, 10, 0, 0, 0), DatumKraja = new DateTime(2026, 3, 5, 23, 59, 0, 0), UslugaId = 6, Status = true, IsDeleted = false, VrijemeBrisanja = null },
            new Promocija { PromocijaId = 8, Naziv = "Keratin popust", Opis = "Keratin tretman po promotivnoj cijeni za glatku, sjajnu i njegovan izgled kose, koji smanjuje kovrčanje i olakšava svakodnevno stiliziranje.", Kod = "CD56EF", Popust = 40, DatumPocetka = new DateTime(2026, 1, 10, 10, 0, 0, 0), DatumKraja = new DateTime(2026, 2, 25, 23, 59, 0, 0), UslugaId = 9, Status = true, IsDeleted = false, VrijemeBrisanja = null },
            new Promocija { PromocijaId = 9, Naziv = "Hidratacija kose", Opis = "Dubinska hidratacija kose po promotivnoj cijeni, pogodna za suhu i oštećenu kosu.", Kod = "GH78IJ", Popust = 25, DatumPocetka = new DateTime(2026, 1, 12, 10, 0, 0, 0), DatumKraja = new DateTime(2026, 3, 1, 23, 59, 0, 0), UslugaId = 10, Status = true, IsDeleted = false, VrijemeBrisanja = null },
            new Promocija { PromocijaId = 10, Naziv = "Uvijanje akcija", Opis = "Iskoristite priliku dok traje promocija – uvijanje kose po sniženoj cijeni za definisane lokne ili blage valove koje će vašem izgledu dati poseban šarm.", Kod = "KL90MN", Popust = 30, DatumPocetka = new DateTime(2026, 1, 11, 10, 0, 0, 0), DatumKraja = new DateTime(2026, 2, 28, 23, 59, 0, 0), UslugaId = 11, Status = true, IsDeleted = false, VrijemeBrisanja = null },

            new Promocija { PromocijaId = 11, Naziv = "Proljetni regenerativni tretman", Opis = "Dubinska obnova kose na popustu! Vaša kosa će biti mekana, sjajna i obnovljena. Savršeno za oštećenu kosu i obnavljanje strukture vlasi.", Kod = "RG07AP", Popust = 20, DatumPocetka = new DateTime(2026, 4, 1, 10, 0, 0, 0), DatumKraja = new DateTime(2026, 4, 15, 23, 59, 0, 0), UslugaId = 7, Status = true, IsDeleted = false, VrijemeBrisanja = null },
            new Promocija { PromocijaId = 12, Naziv = "Elegantna punđa", Opis = "Stilizovanje punđe po promotivnoj cijeni! Idealan izbor za formalne događaje ili elegantan dnevni izgled. Iskoristite priliku i zablistajte.", Kod = "FP14AP", Popust = 25, DatumPocetka = new DateTime(2026, 4, 16, 10, 0, 0, 0), DatumKraja = new DateTime(2026, 4, 29, 23, 59, 0, 0), UslugaId = 14, Status = true, IsDeleted = false, VrijemeBrisanja = null },
            new Promocija { PromocijaId = 13, Naziv = "Muški tretman", Opis = "Uređivanje brade po promotivnoj cijeni za sofisticiran izgled. Iskoristite priliku da oblikujete bradu i postignete uredan, stilizovan izgled.", Kod = "WX56YZ", Popust = 20, DatumPocetka = new DateTime(2026, 2, 27, 10, 0, 0, 0), DatumKraja = new DateTime(2026, 3, 18, 23, 59, 0, 0), UslugaId = 18, Status = true, IsDeleted = false, VrijemeBrisanja = null },
            new Promocija { PromocijaId = 14, Naziv = "Standardno pranje", Opis = "Standardno pranje kose po sniženoj cijeni za čistu i njegovanu kosu. Iskoristite priliku da osjetite svježinu i mekoću svake vlasi.", Kod = "AB78CD", Popust = 25, DatumPocetka = new DateTime(2026, 2, 28, 10, 0, 0, 0), DatumKraja = new DateTime(2026, 3, 12, 23, 59, 0, 0), UslugaId = 19, Status = true, IsDeleted = false, VrijemeBrisanja = null },
            new Promocija { PromocijaId = 15, Naziv = "Peglanje popust", Opis = "Peglanje kose sada po promotivnoj cijeni za glatku i sjajnu kosu. Iskoristite priliku da vaša kosa izgleda besprijekorno svaki dan.", Kod = "EF90GH", Popust = 30, DatumPocetka = new DateTime(2026, 2, 26, 10, 0, 0, 0), DatumKraja = new DateTime(2026, 3, 15, 23, 59, 0, 0), UslugaId = 12, Status = true, IsDeleted = false, VrijemeBrisanja = null }
        );


        modelBuilder.Entity<AktiviranaPromocija>().HasData(
            new AktiviranaPromocija { AktiviranaPromocijaId = 1, PromocijaId = 1, KorisnikId = 5, Aktivirana = true, Iskoristena = true, DatumAktiviranja = new DateTime(2025, 12, 6, 12, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new AktiviranaPromocija { AktiviranaPromocijaId = 2, PromocijaId = 2, KorisnikId = 5, Aktivirana = true, Iskoristena = true, DatumAktiviranja = new DateTime(2025, 12, 12, 11, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new AktiviranaPromocija { AktiviranaPromocijaId = 3, PromocijaId = 3, KorisnikId = 6, Aktivirana = true, Iskoristena = true, DatumAktiviranja = new DateTime(2025, 12, 10, 13, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new AktiviranaPromocija { AktiviranaPromocijaId = 4, PromocijaId = 4, KorisnikId = 6, Aktivirana = true, Iskoristena = true, DatumAktiviranja = new DateTime(2025, 12, 12, 16, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },

            new AktiviranaPromocija { AktiviranaPromocijaId = 5, PromocijaId = 6, KorisnikId = 5, Aktivirana = true, Iskoristena = false, DatumAktiviranja = new DateTime(2026, 1, 3, 10, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new AktiviranaPromocija { AktiviranaPromocijaId = 6, PromocijaId = 7, KorisnikId = 5, Aktivirana = true, Iskoristena = false, DatumAktiviranja = new DateTime(2026, 1, 6, 12, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new AktiviranaPromocija { AktiviranaPromocijaId = 7, PromocijaId = 8, KorisnikId = 6, Aktivirana = true, Iskoristena = false, DatumAktiviranja = new DateTime(2026, 1, 11, 11, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new AktiviranaPromocija { AktiviranaPromocijaId = 8, PromocijaId = 9, KorisnikId = 6, Aktivirana = true, Iskoristena = false, DatumAktiviranja = new DateTime(2026, 1, 13, 14, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null }
        );


        modelBuilder.Entity<Rezervacija>().HasData(
            new Rezervacija { RezervacijaId = 1, KorisnikId = 5, FrizerId = 2, Sifra = "QW8E2R", DatumRezervacije = new DateTime(2025, 12, 10, 0, 0, 0), VrijemePocetka = new TimeSpan(9, 0, 0), VrijemeKraja = new TimeSpan(10, 0, 0), TerminZatvoren = true, UkupnaCijena = 46, UkupnoTrajanje = 60, UkupanBrojUsluga = 2, StateMachine = "zavrsena", NacinPlacanjaId = 1, AktiviranaPromocijaId = 1, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 2, KorisnikId = 5, FrizerId = 2, Sifra = "GH12JK", DatumRezervacije = new DateTime(2025, 12, 15, 0, 0, 0), VrijemePocetka = new TimeSpan(8, 0, 0), VrijemeKraja = new TimeSpan(10, 20, 0), TerminZatvoren = true, UkupnaCijena = 299, UkupnoTrajanje = 140, UkupanBrojUsluga = 2, StateMachine = "zavrsena", NacinPlacanjaId = 1, AktiviranaPromocijaId = 2, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 3, KorisnikId = 6, FrizerId = 3, Sifra = "KL34MN", DatumRezervacije = new DateTime(2025, 12, 16, 0, 0, 0), VrijemePocetka = new TimeSpan(8, 0, 0), VrijemeKraja = new TimeSpan(8, 55, 0), TerminZatvoren = true, UkupnaCijena = 27.75m, UkupnoTrajanje = 55, UkupanBrojUsluga = 2, StateMachine = "zavrsena", NacinPlacanjaId = 2, AktiviranaPromocijaId = 3, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 4, KorisnikId = 6, FrizerId = 4, Sifra = "OP56QR", DatumRezervacije = new DateTime(2025, 12, 20, 0, 0, 0), VrijemePocetka = new TimeSpan(8, 0, 0), VrijemeKraja = new TimeSpan(9, 30, 0), TerminZatvoren = true, UkupnaCijena = 44, UkupnoTrajanje = 90, UkupanBrojUsluga = 2, StateMachine = "zavrsena", NacinPlacanjaId = 2, AktiviranaPromocijaId = 4, IsDeleted = false, VrijemeBrisanja = null },

            new Rezervacija { RezervacijaId = 5, KorisnikId = 6, FrizerId = 4, Sifra = "ZX91TU", DatumRezervacije = new DateTime(2026, 2, 10, 0, 0, 0), VrijemePocetka = new TimeSpan(8, 0, 0), VrijemeKraja = new TimeSpan(9, 0, 0), TerminZatvoren = true, UkupnaCijena = 35, UkupnoTrajanje = 60, UkupanBrojUsluga = 2, StateMachine = "odobrena", NacinPlacanjaId = 1, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 6, KorisnikId = 5, FrizerId = 4, Sifra = "AS72LP", DatumRezervacije = new DateTime(2026, 1, 11, 0, 0, 0), VrijemePocetka = new TimeSpan(9, 0, 0), VrijemeKraja = new TimeSpan(10, 0, 0), TerminZatvoren = true, UkupnaCijena = 35, UkupnoTrajanje = 60, UkupanBrojUsluga = 2, StateMachine = "zavrsena", NacinPlacanjaId = 1, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 7, KorisnikId = 5, FrizerId = 4, Sifra = "ZX91TR", DatumRezervacije = new DateTime(2026, 1, 10, 0, 0, 0), VrijemePocetka = new TimeSpan(8, 0, 0), VrijemeKraja = new TimeSpan(10, 30, 0), TerminZatvoren = true, UkupnaCijena = 270, UkupnoTrajanje = 150, UkupanBrojUsluga = 2, StateMachine = "zavrsena", NacinPlacanjaId = 1, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 8, KorisnikId = 5, FrizerId = 2, Sifra = "LM45OP", DatumRezervacije = new DateTime(2026, 1, 12, 0, 0, 0), VrijemePocetka = new TimeSpan(8, 0, 0), VrijemeKraja = new TimeSpan(8, 45, 0), TerminZatvoren = true, UkupnaCijena = 35, UkupnoTrajanje = 45, UkupanBrojUsluga = 2, StateMachine = "zavrsena", NacinPlacanjaId = 1, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 9, KorisnikId = 6, FrizerId = 3, Sifra = "GH78XY", DatumRezervacije = new DateTime(2026, 1, 11, 0, 0, 0), VrijemePocetka = new TimeSpan(12, 0, 0), VrijemeKraja = new TimeSpan(13, 40, 0), TerminZatvoren = true, UkupnaCijena = 275, UkupnoTrajanje = 100, UkupanBrojUsluga = 2, StateMachine = "zavrsena", NacinPlacanjaId = 2, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },

            new Rezervacija { RezervacijaId = 10, KorisnikId = 5, FrizerId = 2, Sifra = "HZ12LM", DatumRezervacije = new DateTime(2026, 2, 25, 0, 0, 0), VrijemePocetka = new TimeSpan(8, 0, 0), VrijemeKraja = new TimeSpan(9, 0, 0), TerminZatvoren = true, UkupnaCijena = 50, UkupnoTrajanje = 60, UkupanBrojUsluga = 2, StateMachine = "kreirana", NacinPlacanjaId = 1, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },

            new Rezervacija { RezervacijaId = 11, KorisnikId = 5, FrizerId = 2, Sifra = "A7F9KQ", DatumRezervacije = new DateTime(2026, 1, 28, 0, 0, 0), VrijemePocetka = new TimeSpan(10, 30, 0), VrijemeKraja = new TimeSpan(11, 25, 0), TerminZatvoren = true, UkupnaCijena = 30, UkupnoTrajanje = 55, UkupanBrojUsluga = 2, StateMachine = "odobrena", NacinPlacanjaId = 2, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 12, KorisnikId = 6, FrizerId = 3, Sifra = "P4X8LM", DatumRezervacije = new DateTime(2026, 1, 29, 0, 0, 0), VrijemePocetka = new TimeSpan(13, 0, 0), VrijemeKraja = new TimeSpan(14, 30, 0), TerminZatvoren = true, UkupnaCijena = 70, UkupnoTrajanje = 90, UkupanBrojUsluga = 1, StateMachine = "kreirana", NacinPlacanjaId = 2, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 13, KorisnikId = 5, FrizerId = 4, Sifra = "L9M2RZ", DatumRezervacije = new DateTime(2026, 1, 27, 0, 0, 0), VrijemePocetka = new TimeSpan(8, 30, 0), VrijemeKraja = new TimeSpan(9, 20, 0), TerminZatvoren = true, UkupnaCijena = 250, UkupnoTrajanje = 50, UkupanBrojUsluga = 1, StateMachine = "odobrena", NacinPlacanjaId = 1, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 14, KorisnikId = 6, FrizerId = 2, Sifra = "KQ7E2W", DatumRezervacije = new DateTime(2026, 3, 2, 0, 0, 0), VrijemePocetka = new TimeSpan(9, 30, 0), VrijemeKraja = new TimeSpan(11, 00, 0), TerminZatvoren = true, UkupnaCijena = 70, UkupnoTrajanje = 90, UkupanBrojUsluga = 3, StateMachine = "kreirana", NacinPlacanjaId = 2, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 15, KorisnikId = 5, FrizerId = 3, Sifra = "Z5R2MN", DatumRezervacije = new DateTime(2026, 2, 14, 0, 0, 0), VrijemePocetka = new TimeSpan(14, 30, 0), VrijemeKraja = new TimeSpan(15, 20, 0), TerminZatvoren = true, UkupnaCijena = 30, UkupnoTrajanje = 50, UkupanBrojUsluga = 2, StateMachine = "odobrena", NacinPlacanjaId = 1, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 16, KorisnikId = 6, FrizerId = 4, Sifra = "M7Q8YX", DatumRezervacije = new DateTime(2026, 3, 10, 0, 0, 0), VrijemePocetka = new TimeSpan(10, 0, 0), VrijemeKraja = new TimeSpan(11, 10, 0), TerminZatvoren = false, UkupnaCijena = 45, UkupnoTrajanje = 70, UkupanBrojUsluga = 2, StateMachine = "ponistena", NacinPlacanjaId = 1, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 17, KorisnikId = 5, FrizerId = 2, Sifra = "K5P9LA", DatumRezervacije = new DateTime(2026, 1, 27, 0, 0, 0), VrijemePocetka = new TimeSpan(13, 30, 0), VrijemeKraja = new TimeSpan(14, 0, 0), TerminZatvoren = false, UkupnaCijena = 30, UkupnoTrajanje = 30, UkupanBrojUsluga = 1, StateMachine = "ponistena", NacinPlacanjaId = 1, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 18, KorisnikId = 6, FrizerId = 3, Sifra = "Q8L3ZM", DatumRezervacije = new DateTime(2026, 2, 24, 0, 0, 0), VrijemePocetka = new TimeSpan(13, 0, 0), VrijemeKraja = new TimeSpan(14, 55, 0), TerminZatvoren = true, UkupnaCijena = 85, UkupnoTrajanje = 115, UkupanBrojUsluga = 3, StateMachine = "odobrena", NacinPlacanjaId = 2, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 19, KorisnikId = 5, FrizerId = 3, Sifra = "K8P9ZQ", DatumRezervacije = new DateTime(2026, 2, 24, 0, 0, 0), VrijemePocetka = new TimeSpan(8, 0, 0), VrijemeKraja = new TimeSpan(9, 0, 0), TerminZatvoren = true, UkupnaCijena = 200, UkupnoTrajanje = 60, UkupanBrojUsluga = 1, StateMachine = "kreirana", NacinPlacanjaId = 2, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null },
            new Rezervacija { RezervacijaId = 20, KorisnikId = 6, FrizerId = 4, Sifra = "A9R2WX", DatumRezervacije = new DateTime(2026, 1, 30, 0, 0, 0), VrijemePocetka = new TimeSpan(10, 00, 0), VrijemeKraja = new TimeSpan(11, 40, 0), TerminZatvoren = true, UkupnaCijena = 65, UkupnoTrajanje = 100, UkupanBrojUsluga = 3, StateMachine = "kreirana", NacinPlacanjaId = 1, AktiviranaPromocijaId = null, IsDeleted = false, VrijemeBrisanja = null }

        );


        modelBuilder.Entity<StavkeRezervacije>().HasData(
            new StavkeRezervacije { StavkeRezervacijeId = 1, UslugaId = 1, RezervacijaId = 1, Cijena = 16, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 2, UslugaId = 12, RezervacijaId = 1, Cijena = 30, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 3, UslugaId = 5, RezervacijaId = 2, Cijena = 49, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 4, UslugaId = 8, RezervacijaId = 2, Cijena = 250, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 5, UslugaId = 3, RezervacijaId = 3, Cijena = 12.75m, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 6, UslugaId = 19, RezervacijaId = 3, Cijena = 15, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 7, UslugaId = 4, RezervacijaId = 4, Cijena = 24, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 8, UslugaId = 20, RezervacijaId = 4, Cijena = 20, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 9, UslugaId = 17, RezervacijaId = 5, Cijena = 20, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 10, UslugaId = 18, RezervacijaId = 5, Cijena = 15, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 11, UslugaId = 17, RezervacijaId = 6, Cijena = 20, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 12, UslugaId = 18, RezervacijaId = 6, Cijena = 15, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 13, UslugaId = 20, RezervacijaId = 7, Cijena = 20, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 14, UslugaId = 15, RezervacijaId = 7, Cijena = 250, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 15, UslugaId = 13, RezervacijaId = 8, Cijena = 20, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 16, UslugaId = 19, RezervacijaId = 8, Cijena = 15, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 17, UslugaId = 2, RezervacijaId = 9, Cijena = 25, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 18, UslugaId = 8, RezervacijaId = 9, Cijena = 250, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 19, UslugaId = 1, RezervacijaId = 10, Cijena = 20, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 20, UslugaId = 12, RezervacijaId = 10, Cijena = 30, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 21, UslugaId = 3, RezervacijaId = 11, Cijena = 15, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 22, UslugaId = 19, RezervacijaId = 11, Cijena = 15, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 23, UslugaId = 5, RezervacijaId = 12, Cijena = 70, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 24, UslugaId = 8, RezervacijaId = 13, Cijena = 250, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 25, UslugaId = 1, RezervacijaId = 14, Cijena = 20, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 26, UslugaId = 12, RezervacijaId = 14, Cijena = 30, IsDeleted = false, VrijemeBrisanja = null }, 
            new StavkeRezervacije { StavkeRezervacijeId = 27, UslugaId = 20, RezervacijaId = 14, Cijena = 20, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 28, UslugaId = 16, RezervacijaId = 15, Cijena = 15, IsDeleted = false, VrijemeBrisanja = null }, 
            new StavkeRezervacije { StavkeRezervacijeId = 29, UslugaId = 18, RezervacijaId = 15, Cijena = 15, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 30, UslugaId = 2, RezervacijaId = 16, Cijena = 25, IsDeleted = false, VrijemeBrisanja = null }, 
            new StavkeRezervacije { StavkeRezervacijeId = 31, UslugaId = 13, RezervacijaId = 16, Cijena = 20, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 32, UslugaId = 12, RezervacijaId = 17, Cijena = 30, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 33, UslugaId = 19, RezervacijaId = 18, Cijena = 15, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 34, UslugaId = 4, RezervacijaId = 18, Cijena = 40, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 35, UslugaId = 11, RezervacijaId = 18, Cijena = 30, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 36, UslugaId = 10, RezervacijaId = 19, Cijena = 200, IsDeleted = false, VrijemeBrisanja = null },

            new StavkeRezervacije { StavkeRezervacijeId = 37, UslugaId = 20, RezervacijaId = 20, Cijena = 20, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 38, UslugaId = 2, RezervacijaId = 20, Cijena = 25, IsDeleted = false, VrijemeBrisanja = null },
            new StavkeRezervacije { StavkeRezervacijeId = 39, UslugaId = 13, RezervacijaId = 20, Cijena = 20, IsDeleted = false, VrijemeBrisanja = null }

        );

        modelBuilder.Entity<Ocjena>().HasData(
            new Ocjena { OcjenaId = 1, UslugaId = 1, KorisnikId = 5, Vrijednost = 5, DatumOcjenjivanja = new DateTime(2025, 12, 11, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Ocjena { OcjenaId = 2, UslugaId = 12, KorisnikId = 5, Vrijednost = 4, DatumOcjenjivanja = new DateTime(2025, 12, 11, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },

            new Ocjena { OcjenaId = 3, UslugaId = 5, KorisnikId = 5, Vrijednost = 5, DatumOcjenjivanja = new DateTime(2025, 12, 16, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Ocjena { OcjenaId = 4, UslugaId = 8, KorisnikId = 5, Vrijednost = 4, DatumOcjenjivanja = new DateTime(2025, 12, 16, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },

            new Ocjena { OcjenaId = 5, UslugaId = 3, KorisnikId = 6, Vrijednost = 4, DatumOcjenjivanja = new DateTime(2025, 12, 17, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Ocjena { OcjenaId = 6, UslugaId = 19, KorisnikId = 6, Vrijednost = 5, DatumOcjenjivanja = new DateTime(2025, 12, 17, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },

            new Ocjena { OcjenaId = 7, UslugaId = 4, KorisnikId = 6, Vrijednost = 3, DatumOcjenjivanja = new DateTime(2025, 12, 21, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Ocjena { OcjenaId = 8, UslugaId = 20, KorisnikId = 6, Vrijednost = 4, DatumOcjenjivanja = new DateTime(2025, 12, 21, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },

            new Ocjena { OcjenaId = 9, UslugaId = 17, KorisnikId = 5, Vrijednost = 5, DatumOcjenjivanja = new DateTime(2026, 2, 11, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Ocjena { OcjenaId = 10, UslugaId = 18, KorisnikId = 5, Vrijednost = 4, DatumOcjenjivanja = new DateTime(2026, 2, 11, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },

            new Ocjena { OcjenaId = 11, UslugaId = 20, KorisnikId = 5, Vrijednost = 5, DatumOcjenjivanja = new DateTime(2026, 1, 11, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Ocjena { OcjenaId = 12, UslugaId = 15, KorisnikId = 5, Vrijednost = 4, DatumOcjenjivanja = new DateTime(2026, 1, 11, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },

            new Ocjena { OcjenaId = 13, UslugaId = 8, KorisnikId = 6, Vrijednost = 4, DatumOcjenjivanja = new DateTime(2026, 1, 12, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new Ocjena { OcjenaId = 14, UslugaId = 19, KorisnikId = 5, Vrijednost = 5, DatumOcjenjivanja = new DateTime(2026, 2, 13, 0, 0, 0), IsDeleted = false, VrijemeBrisanja = null }

        );


        modelBuilder.Entity<Recenzija>().HasData(
            new Recenzija { RecenzijaId = 1, KorisnikId = 5, UslugaId = 1, Komentar = "Sjajno šišanje, kosa je uredno oblikovana i vrlo sam zadovoljna rezultatom.", DatumDodavanja = new DateTime(2025, 12, 11, 10, 0, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new Recenzija { RecenzijaId = 2, KorisnikId = 5, UslugaId = 12, Komentar = "Peglanje kose je bilo besprijekorno, kosa je ostala ravna cijeli dan.", DatumDodavanja = new DateTime(2025, 12, 11, 11, 0, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new Recenzija { RecenzijaId = 3, KorisnikId = 5, UslugaId = 5, Komentar = "Balayage je ispao prirodno i prekrasno, jako sam zadovoljna.", DatumDodavanja = new DateTime(2025, 12, 16, 10, 0, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new Recenzija { RecenzijaId = 4, KorisnikId = 5, UslugaId = 8, Komentar = "Tretman protiv opadanja kose je djelovao od prvog dana, vlasište je puno zdravije.", DatumDodavanja = new DateTime(2025, 12, 16, 12, 0, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new Recenzija { RecenzijaId = 5, KorisnikId = 6, UslugaId = 3, Komentar = "Dječije šišanje je prošlo super, dijete je bilo mirno i zadovoljno.", DatumDodavanja = new DateTime(2025, 12, 17, 10, 0, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new Recenzija { RecenzijaId = 6, KorisnikId = 6, UslugaId = 19, Komentar = "Pranje kose je bilo odlično, kosa je čista i svilenkasta, a masaža opuštajuća.", DatumDodavanja = new DateTime(2025, 12, 17, 11, 0, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new Recenzija { RecenzijaId = 7, KorisnikId = 5, UslugaId = 17, Komentar = "Šišanje je perfektno, rezultat je uredan i moderan.", DatumDodavanja = new DateTime(2026, 1, 12, 10, 0, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new Recenzija { RecenzijaId = 8, KorisnikId = 5, UslugaId = 18, Komentar = "Uređivanje brade je vrlo precizno, baš kako sam htio.", DatumDodavanja = new DateTime(2026, 1, 12, 11, 0, 0), BrojLajkova = 0, BrojDislajkova = 1, IsDeleted = false, VrijemeBrisanja = null },
            new Recenzija { RecenzijaId = 9, KorisnikId = 5, UslugaId = 20, Komentar = "Temeljito pranje kose je osvježilo moju kosu, savršeno iskustvo.", DatumDodavanja = new DateTime(2026, 1, 13, 10, 0, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new Recenzija { RecenzijaId = 10, KorisnikId = 6, UslugaId = 8, Komentar = "Tretman protiv opadanja kose djeluje super, kosa je gušća nego prije.", DatumDodavanja = new DateTime(2026, 1, 12, 10, 0, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new Recenzija { RecenzijaId = 11, KorisnikId = 5, UslugaId = 19, Komentar = "Pranje kose je bilo vrlo prijatno, masaža vlasišta je opuštajuća, a kosa je poslije veoma mekana i sjajna.", DatumDodavanja = new DateTime(2026, 1, 12, 10, 0, 0), BrojLajkova = 0, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new Recenzija { RecenzijaId = 12, KorisnikId = 6, UslugaId = 20, Komentar = "Kosa je nakon pranja mekana, čista i svilenkasta, osjećaj je vrlo osvježavajući.", DatumDodavanja = new DateTime(2026, 1, 12, 11, 0, 0), BrojLajkova = 0, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null }
        );

        modelBuilder.Entity<RecenzijaReakcija>().HasData(
            new RecenzijaReakcija { RecenzijaReakcijaId = 1, RecenzijaId = 1, KorisnikId = 6, JeLajk = true, DatumReakcije = new DateTime(2025, 12, 12, 10, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaReakcija { RecenzijaReakcijaId = 2, RecenzijaId = 2, KorisnikId = 6, JeLajk = true, DatumReakcije = new DateTime(2025, 12, 12, 11, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaReakcija { RecenzijaReakcijaId = 3, RecenzijaId = 3, KorisnikId = 6, JeLajk = true, DatumReakcije = new DateTime(2025, 12, 17, 12, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaReakcija { RecenzijaReakcijaId = 4, RecenzijaId = 4, KorisnikId = 6, JeLajk = true, DatumReakcije = new DateTime(2025, 12, 17, 13, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaReakcija { RecenzijaReakcijaId = 5, RecenzijaId = 5, KorisnikId = 5, JeLajk = true, DatumReakcije = new DateTime(2025, 12, 18, 10, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaReakcija { RecenzijaReakcijaId = 6, RecenzijaId = 6, KorisnikId = 5, JeLajk = true, DatumReakcije = new DateTime(2025, 12, 18, 11, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaReakcija { RecenzijaReakcijaId = 7, RecenzijaId = 7, KorisnikId = 6, JeLajk = true, DatumReakcije = new DateTime(2026, 1, 13, 10, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaReakcija { RecenzijaReakcijaId = 8, RecenzijaId = 8, KorisnikId = 6, JeLajk = false, DatumReakcije = new DateTime(2026, 1, 13, 11, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaReakcija { RecenzijaReakcijaId = 9, RecenzijaId = 9, KorisnikId = 6, JeLajk = true, DatumReakcije = new DateTime(2026, 1, 14, 10, 0, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaReakcija { RecenzijaReakcijaId = 10, RecenzijaId = 10, KorisnikId = 5, JeLajk = true, DatumReakcije = new DateTime(2026, 1, 13, 10, 0, 0), IsDeleted = false, VrijemeBrisanja = null }
        );

       

        modelBuilder.Entity<RecenzijaOdgovor>().HasData(
            new RecenzijaOdgovor { RecenzijaOdgovorId = 1, RecenzijaId = 1, KorisnikId = 6, Komentar = "Kosa izgleda stvarno uredno nakon šišanja, meni se moja jako dopada.", DatumDodavanja = new DateTime(2025, 12, 12, 9, 30, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovor { RecenzijaOdgovorId = 2, RecenzijaId = 1, KorisnikId = 5, Komentar = "Drago mi je da si zadovoljna krajnjim rezultatom kao i ja sa svojim.", DatumDodavanja = new DateTime(2025, 12, 12, 9, 40, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },

            new RecenzijaOdgovor { RecenzijaOdgovorId = 3, RecenzijaId = 6, KorisnikId = 5, Komentar = "Drago mi je da si uživala u pranju kao i ja, masaža zaista opušta.", DatumDodavanja = new DateTime(2025, 12, 18, 11, 5, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovor { RecenzijaOdgovorId = 4, RecenzijaId = 6, KorisnikId = 6, Komentar = "Da, osjećaj nakon pranja je stvarno osvježavajući.", DatumDodavanja = new DateTime(2025, 12, 18, 11, 10, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },

            new RecenzijaOdgovor { RecenzijaOdgovorId = 5, RecenzijaId = 9, KorisnikId = 6, Komentar = "Kosa je stvarno mekša nego prije, super osjećaj.", DatumDodavanja = new DateTime(2026, 1, 14, 10, 5, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovor { RecenzijaOdgovorId = 6, RecenzijaId = 9, KorisnikId = 5, Komentar = "Drago mi je da primjećuješ razliku kao i ja, cilj je imati baš ovakav osjećaj.", DatumDodavanja = new DateTime(2026, 1, 14, 10, 10, 0), BrojLajkova = 0, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },

            new RecenzijaOdgovor { RecenzijaOdgovorId = 7, RecenzijaId = 3, KorisnikId = 6, Komentar = "Rezultat je stvarno prirodan, sve pohvale.", DatumDodavanja = new DateTime(2025, 12, 17, 10, 5, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovor { RecenzijaOdgovorId = 8, RecenzijaId = 3, KorisnikId = 5, Komentar = "Tako je, stvarno sam zadovoljna jer je efekat baš prirodan i svjež.", DatumDodavanja = new DateTime(2025, 12, 17, 10, 10, 0), BrojLajkova = 0, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },

            new RecenzijaOdgovor { RecenzijaOdgovorId = 9, RecenzijaId = 11, KorisnikId = 6, Komentar = "Kosa je stvarno mekša i sjajnija, odlično iskustvo.", DatumDodavanja = new DateTime(2026, 1, 12, 10, 5, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovor { RecenzijaOdgovorId = 10, RecenzijaId = 11, KorisnikId = 5, Komentar = "Drago mi je da i ti primjećuješ efekat, baš je cilj da kosa bude mekša. Sve preporuke.", DatumDodavanja = new DateTime(2026, 1, 12, 10, 10, 0), BrojLajkova = 0, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },

            new RecenzijaOdgovor { RecenzijaOdgovorId = 11, RecenzijaId = 10, KorisnikId = 5, Komentar = "Super što tretman daje vidljive rezultate, kosa je stvarno gušća.", DatumDodavanja = new DateTime(2026, 1, 12, 10, 5, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovor { RecenzijaOdgovorId = 12, RecenzijaId = 10, KorisnikId = 6, Komentar = "Da, stvarno se osjeti poboljšanje, kosa je puno zdravija.", DatumDodavanja = new DateTime(2026, 1, 12, 10, 10, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovor { RecenzijaOdgovorId = 13, RecenzijaId = 10, KorisnikId = 5, Komentar = "Drago mi je da i ti primjećuješ razliku. Sve pohvale stvarno za tretman.", DatumDodavanja = new DateTime(2026, 1, 12, 10, 15, 0), BrojLajkova = 1, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },
            
            new RecenzijaOdgovor { RecenzijaOdgovorId = 14, RecenzijaId = 8, KorisnikId = 6, Komentar = "Daa, krajnji rezultat je baš super.", DatumDodavanja = new DateTime(2026, 1, 12, 11, 5, 0), BrojLajkova = 0, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null },

            new RecenzijaOdgovor { RecenzijaOdgovorId = 15, RecenzijaId = 4, KorisnikId = 6, Komentar = "Primijetila sam poboljšanje u teksturi kose i vlasište izgleda zdravije, stvarno djeluje.", DatumDodavanja = new DateTime(2025, 12, 16, 12, 10, 0), BrojLajkova = 0, BrojDislajkova = 0, IsDeleted = false, VrijemeBrisanja = null }

        );

        modelBuilder.Entity<RecenzijaOdgovorReakcija>().HasData(
            new RecenzijaOdgovorReakcija { RecenzijaOdgovorReakcijaId = 1, RecenzijaOdgovorId = 1, KorisnikId = 5, JeLajk = true, DatumReakcije = new DateTime(2025, 12, 12, 9, 35, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovorReakcija { RecenzijaOdgovorReakcijaId = 2, RecenzijaOdgovorId = 3, KorisnikId = 6, JeLajk = true, DatumReakcije = new DateTime(2025, 12, 18, 11, 8, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovorReakcija { RecenzijaOdgovorReakcijaId = 3, RecenzijaOdgovorId = 5, KorisnikId = 5, JeLajk = true, DatumReakcije = new DateTime(2026, 1, 14, 10, 7, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovorReakcija { RecenzijaOdgovorReakcijaId = 4, RecenzijaOdgovorId = 7, KorisnikId = 5, JeLajk = true, DatumReakcije = new DateTime(2025, 12, 17, 10, 8, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovorReakcija { RecenzijaOdgovorReakcijaId = 5, RecenzijaOdgovorId = 9, KorisnikId = 5, JeLajk = true, DatumReakcije = new DateTime(2026, 1, 12, 10, 6, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovorReakcija { RecenzijaOdgovorReakcijaId = 6, RecenzijaOdgovorId = 11, KorisnikId = 6, JeLajk = true, DatumReakcije = new DateTime(2026, 1, 12, 10, 7, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovorReakcija { RecenzijaOdgovorReakcijaId = 7, RecenzijaOdgovorId = 12, KorisnikId = 5, JeLajk = true, DatumReakcije = new DateTime(2026, 1, 12, 10, 12, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovorReakcija { RecenzijaOdgovorReakcijaId = 8, RecenzijaOdgovorId = 13, KorisnikId = 6, JeLajk = true, DatumReakcije = new DateTime(2026, 1, 12, 10, 16, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovorReakcija { RecenzijaOdgovorReakcijaId = 9, RecenzijaOdgovorId = 2, KorisnikId = 6, JeLajk = true, DatumReakcije = new DateTime(2025, 12, 12, 9, 45, 0), IsDeleted = false, VrijemeBrisanja = null },
            new RecenzijaOdgovorReakcija { RecenzijaOdgovorReakcijaId = 10, RecenzijaOdgovorId = 4, KorisnikId = 5, JeLajk = true, DatumReakcije = new DateTime(2025, 12, 18, 11, 12, 0), IsDeleted = false, VrijemeBrisanja = null }
        );


        modelBuilder.Entity<Obavijest>().HasData(
  
            new Obavijest
            {
                ObavijestId = 1,
                KorisnikId = 5,
                Naslov = "Nova usluga u eSalonu",
                Sadrzaj = "Pozdrav Klijent,\n\n" +
                          "Nova usluga 'Ekstenzije i nadogradnja kose' je sada dostupna u našem salonu. " +
                          "Dođite i isprobajte je!\n\n" +
                          "Vaš eSalon tim",
                DatumObavijesti = new DateTime(2025, 1, 20, 10, 0, 0),
                JePogledana = true,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Obavijest
            {
                ObavijestId = 2,
                KorisnikId = 5,
                Naslov = "Nova usluga u eSalonu",
                Sadrzaj = "Pozdrav Klijent,\n\n" +
                          "Nova usluga 'Keratin tretman' je sada dostupna u našem salonu. " +
                          "Dođite i isprobajte je!\n\n" +
                          "Vaš eSalon tim",
                DatumObavijesti = new DateTime(2025, 1, 19, 10, 5, 0),
                JePogledana = false,
                IsDeleted = false,
                VrijemeBrisanja = null
            },

            new Obavijest
            {
                ObavijestId = 3,
                KorisnikId = 6,
                Naslov = "Nova usluga u eSalonu",
                Sadrzaj = "Pozdrav KlijentDva,\n\n" +
                          "Nova usluga 'Ekstenzije i nadogradnja kose' je sada dostupna u našem salonu. " +
                          "Dođite i isprobajte je!\n\n" +
                          "Vaš eSalon tim",
                DatumObavijesti = new DateTime(2025, 1, 20, 10, 10, 0),
                JePogledana = false,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Obavijest
            {
                ObavijestId = 4,
                KorisnikId = 6,
                Naslov = "Nova usluga u eSalonu",
                Sadrzaj = "Pozdrav KlijentDva,\n\n" +
                          "Nova usluga 'Keratin tretman' je sada dostupna u našem salonu. " +
                          "Dođite i isprobajte je!\n\n" +
                          "Vaš eSalon tim",
                DatumObavijesti = new DateTime(2025, 1, 19, 10, 15, 0),
                JePogledana = true,
                IsDeleted = false,
                VrijemeBrisanja = null
            },

            new Obavijest
            {
                ObavijestId = 5,
                KorisnikId = 5,
                Naslov = "Vaša rezervacija je odobrena",
                Sadrzaj = "Poštovanje Klijent,\n\n" +
                  "Vaša rezervacija u salonu je odobrena od strane frizera FrizerDva. " +
                  "Molimo Vas da planirate dolazak prema odabranom terminu.\n\n" +
                  "Detalji rezervacije:\n" +
                  "- Šifra rezervacije: #Z5R2MN\n" +
                  "- Klijent: Klijent Klijent\n" +
                  "- Frizer: FrizerDva\n" +
                  "- Datum rezervacije: 14.02.2026\n" +
                  "- Vrijeme rezervacije: 14:30 - 15:20\n" +
                  "- Broj usluga: 2\n" +
                  "- Ukupan iznos: 30 KM\n\n" +
                  "Hvala na rezervaciji!\n" +
                  "Vaš eSalon tim",
                DatumObavijesti = new DateTime(2026, 1, 12, 11, 0, 0),
                JePogledana = false,
                IsDeleted = false,
                VrijemeBrisanja = null
            },

            new Obavijest
            {
                ObavijestId = 6,
                KorisnikId = 6,
                Naslov = "Vaša rezervacija je odobrena",
                Sadrzaj = "Poštovanje KlijentDva,\n\n" +
                          "Vaša rezervacija u salonu je odobrena od strane frizera FrizerDva. " +
                          "Molimo Vas da planirate dolazak prema odabranom terminu.\n\n" +
                          "Detalji rezervacije:\n" +
                          "- Šifra rezervacije: #Q8L3ZM\n" +
                          "- Klijent: KlijentDva KlijentDva\n" +
                          "- Frizer: FrizerDva\n" +
                          "- Datum rezervacije: 24.02.2026\n" +
                          "- Vrijeme rezervacije: 13:00 - 14:55\n" +
                          "- Broj usluga: 3\n" +
                          "- Ukupan iznos: 85 KM\n\n" +
                          "Hvala na rezervaciji!\n" +
                          "Vaš eSalon tim",
                DatumObavijesti = new DateTime(2026, 1, 11, 11, 5, 0),
                JePogledana = false,
                IsDeleted = false,
                VrijemeBrisanja = null
            },


            new Obavijest
            {
                ObavijestId = 7,
                KorisnikId = 3, 
                Naslov = "Nova rezervacija",
                Sadrzaj = "Poštovanje FrizerDva,\n\n" +
                  "Kreirana je nova rezervacija #Z5R2MN za datum 14.02.2026.\n" +
                  "Molimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\n" +
                  "Hvala,\nVaš eSalon tim",
                DatumObavijesti = new DateTime(2026, 1, 13, 12, 0, 0),
                JePogledana = true,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Obavijest
            {
                ObavijestId = 8,
                KorisnikId = 3, 
                Naslov = "Nova rezervacija",
                Sadrzaj = "Poštovanje FrizerDva,\n\n" +
                          "Kreirana je nova rezervacija #Q8L3ZM za datum 24.02.2026.\n" +
                          "Molimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\n" +
                          "Hvala,\nVaš eSalon tim",
                DatumObavijesti = new DateTime(2026, 1, 12, 12, 5, 0),
                JePogledana = false,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Obavijest
            {
                ObavijestId = 9,
                KorisnikId = 3, 
                Naslov = "Nova rezervacija",
                Sadrzaj = "Poštovanje FrizerDva,\n\n" +
              "Kreirana je nova rezervacija #P4X8LM za datum 29.01.2026.\n" +
              "Molimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\n" +
              "Hvala,\nVaš eSalon tim",
                DatumObavijesti = new DateTime(2026, 1, 11, 12, 10, 0),
                JePogledana = false,
                IsDeleted = false,
                VrijemeBrisanja = null
            },


            new Obavijest
            {
                ObavijestId = 10,
                KorisnikId = 2, 
                Naslov = "Nova rezervacija",
                Sadrzaj = "Poštovanje Frizer,\n\n" +
              "Kreirana je nova rezervacija #A7F9KQ za datum 28.01.2026.\n" +
              "Molimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\n" +
              "Hvala,\nVaš eSalon tim",
                DatumObavijesti = new DateTime(2026, 1, 12, 12, 20, 0),
                JePogledana = false,
                IsDeleted = false,
                VrijemeBrisanja = null
            },
            new Obavijest
            {
                ObavijestId = 11,
                KorisnikId = 2,
                Naslov = "Nova rezervacija",
                Sadrzaj = "Poštovanje Frizer,\n\n" +
                          "Kreirana je nova rezervacija #KQ7E2W za datum 02.03.2026.\n" +
                          "Molimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\n" +
                          "Hvala,\nVaš eSalon tim",
                DatumObavijesti = new DateTime(2026, 1, 11, 12, 25, 0),
                JePogledana = true,
                IsDeleted = false,
                VrijemeBrisanja = null
            },


            new Obavijest
            {
                ObavijestId = 12,
                KorisnikId = 4, 
                Naslov = "Nova rezervacija",
                Sadrzaj = "Poštovanje FrizerTri,\n\n" +
              "Kreirana je nova rezervacija #L9M2RZ za datum 27.01.2026.\n" +
              "Molimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\n" +
              "Hvala,\nVaš eSalon tim",
                DatumObavijesti = new DateTime(2026, 1, 11, 12, 40, 0),
                JePogledana = true,
                IsDeleted = false,
                VrijemeBrisanja = null
            },

            new Obavijest
            {
                ObavijestId = 13,
                KorisnikId = 4, 
                Naslov = "Nova rezervacija",
                Sadrzaj = "Poštovanje FrizerTri,\n\n" +
                          "Kreirana je nova rezervacija #A9R2WX za datum 30.01.2026.\n" +
                          "Molimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.\n\n" +
                          "Hvala,\nVaš eSalon tim",
                DatumObavijesti = new DateTime(2026, 1, 11, 12, 45, 0),
                JePogledana = false,
                IsDeleted = false,
                VrijemeBrisanja = null
            },

            new Obavijest
            {
                ObavijestId = 14,
                KorisnikId = 6,
                Naslov = "Rezervacija je otkazana",
                Sadrzaj = "Poštovanje KlijentDva,\n\n" +
              "Nažalost, Vaša rezervacija sa šifrom #M7Q8YX, zakazana za 10.03.2026, je otkazana od strane frizera. " +
              "Iskreno nam je žao zbog ove promjene i nadamo se da ćemo Vas uskoro moći ugostiti u našem salonu i pružiti Vam vrhunsku uslugu.\n\n" +
              "Hvala na razumijevanju,\nVaš eSalon tim",
                DatumObavijesti = new DateTime(2026, 1, 11, 13, 0, 0),
                JePogledana = false,
                IsDeleted = false,
                VrijemeBrisanja = null
            },

            new Obavijest
            {
                ObavijestId = 15,
                KorisnikId = 5, 
                Naslov = "Rezervacija je otkazana",
                Sadrzaj = "Poštovanje Klijent,\n\n" +
                          "Nažalost, Vaša rezervacija sa šifrom #K5P9LA, zakazana za 27.01.2026, je otkazana od strane frizera. " +
                          "Iskreno nam je žao zbog ove promjene i nadamo se da ćemo Vas uskoro moći ugostiti u našem salonu i pružiti Vam vrhunsku uslugu.\n\n" +
                          "Hvala na razumijevanju,\nVaš eSalon tim",
                DatumObavijesti = new DateTime(2026, 1, 11, 13, 5, 0),
                JePogledana = false,
                IsDeleted = false,
                VrijemeBrisanja = null
            }

        );


    }
}
