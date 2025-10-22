import 'package:json_annotation/json_annotation.dart';

part 'ocjena.g.dart';

@JsonSerializable()
class Ocjena {
  int? ocjenaId;
  int? uslugaId;
  int? korisnikId;
  int? vrijednost;
  DateTime? datumOcjenjivanja;

  Ocjena(
    this.ocjenaId,
    this.uslugaId,
    this.korisnikId,
    this.vrijednost,
    this.datumOcjenjivanja,
  );

  factory Ocjena.fromJson(Map<String, dynamic> json) => _$OcjenaFromJson(json);

  Map<String, dynamic> toJson() => _$OcjenaToJson(this);
}
