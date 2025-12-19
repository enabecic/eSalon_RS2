import 'package:json_annotation/json_annotation.dart';

part 'recenzija.g.dart';

@JsonSerializable()
class Recenzija {
  int? recenzijaId;
  int korisnikId;
  int uslugaId;
  String komentar;
  DateTime datumDodavanja;
  int brojLajkova;
  int brojDislajkova;
  String? korisnickoIme;
  String? nazivUsluge;
  int brojOdgovora;
  bool jeLajkOdKorisnika;
  bool jeDislajkOdKorisnika;

  Recenzija(
    this.recenzijaId,
    this.korisnikId,
    this.uslugaId,
    this.komentar,
    this.datumDodavanja,
    this.brojLajkova,
    this.brojDislajkova,
    this.korisnickoIme,
    this.nazivUsluge,
    this.brojOdgovora,
    this.jeLajkOdKorisnika, 
    this.jeDislajkOdKorisnika,  
  );
  
  factory Recenzija.fromJson(Map<String, dynamic> json) => _$RecenzijaFromJson(json);

  Map<String, dynamic> toJson() => _$RecenzijaToJson(this);
}