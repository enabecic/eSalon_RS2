import 'package:esalon_mobile/models/stavke_rezervacije.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rezervacija.g.dart';

@JsonSerializable()
class Rezervacija {
  int? rezervacijaId;
  int? korisnikId;
  int? frizerId;
  String? sifra;
  DateTime? datumRezervacije;
  String? vrijemePocetka; 
  String? vrijemeKraja; 
  bool? terminZatvoren;
  double? ukupnaCijena;
  int? ukupnoTrajanje;
  int? ukupanBrojUsluga;
  String? stateMachine;
  int? nacinPlacanjaId;
  int? aktiviranaPromocijaId;
  String? aktiviranaPromocijaNaziv;
  String? frizerImePrezime;
  String? klijentImePrezime;
  String? nacinPlacanjaNaziv;
  List<StavkeRezervacije>? stavkeRezervacijes;

  Rezervacija({
    this.rezervacijaId,
    this.korisnikId,
    this.frizerId,
    this.sifra,
    this.datumRezervacije,
    this.vrijemePocetka,
    this.vrijemeKraja,
    this.terminZatvoren,
    this.ukupnaCijena,
    this.ukupnoTrajanje,
    this.ukupanBrojUsluga,
    this.stateMachine,
    this.nacinPlacanjaId,
    this.aktiviranaPromocijaId,
    this.aktiviranaPromocijaNaziv,
    this.frizerImePrezime,
    this.klijentImePrezime,
    this.nacinPlacanjaNaziv,
    this.stavkeRezervacijes,
  });

  factory Rezervacija.fromJson(Map<String, dynamic> json) =>
      _$RezervacijaFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$RezervacijaToJson(this);
}