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

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
