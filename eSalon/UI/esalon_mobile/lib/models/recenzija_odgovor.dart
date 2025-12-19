import 'package:json_annotation/json_annotation.dart';

part 'recenzija_odgovor.g.dart';

@JsonSerializable()
class RecenzijaOdgovor {
  int? recenzijaOdgovorId;
  int recenzijaId;
  int korisnikId;
  String komentar;
  DateTime datumDodavanja;
  int brojLajkova;
  int brojDislajkova;
  String? korisnickoIme;
  String? komentarRecenzije;
  String? nazivUsluge;

  RecenzijaOdgovor(
    this.recenzijaOdgovorId,
    this.recenzijaId,
    this.korisnikId,
    this.komentar,
    this.datumDodavanja,
    this.brojLajkova,
    this.brojDislajkova,
    this.korisnickoIme,
    this.komentarRecenzije,
    this.nazivUsluge,
  );

  factory RecenzijaOdgovor.fromJson(Map<String, dynamic> json) => _$RecenzijaOdgovorFromJson(json);

  Map<String, dynamic> toJson() => _$RecenzijaOdgovorToJson(this);
}