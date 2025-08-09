import 'package:json_annotation/json_annotation.dart';

part 'arhiva.g.dart';

@JsonSerializable()
class Arhiva {
  int? arhivaId;
  int? korisnikId;
  int? uslugaId;
  DateTime? datumDodavanja;
  String? uslugaNaziv;
  double? cijena;
  String? slika;
  int? trajanje;

  Arhiva({
    this.arhivaId,
    this.korisnikId,
    this.uslugaId,
    this.datumDodavanja,
    this.uslugaNaziv,
    this.cijena,
    this.slika,
    this.trajanje,
  });

  factory Arhiva.fromJson(Map<String, dynamic> json) => _$ArhivaFromJson(json);
  Map<String, dynamic> toJson() => _$ArhivaToJson(this);
}
