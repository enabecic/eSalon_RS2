import 'package:json_annotation/json_annotation.dart';

part 'obavijest.g.dart';

@JsonSerializable()
class Obavijest {
  int obavijestId;
  int korisnikId;
  String naslov;
  String sadrzaj;
  DateTime datumObavijesti;
  bool jePogledana;
  String? imePrezime;

  Obavijest(
    this.obavijestId,
    this.korisnikId,
    this.naslov,
    this.sadrzaj,
    this.datumObavijesti,
    this.jePogledana,
    this.imePrezime,
  );

  factory Obavijest.fromJson(Map<String, dynamic> json) => _$ObavijestFromJson(json);

  Map<String, dynamic> toJson() => _$ObavijestToJson(this);
}
