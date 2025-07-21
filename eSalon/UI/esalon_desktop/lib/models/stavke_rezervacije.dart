import 'package:json_annotation/json_annotation.dart';

part 'stavke_rezervacije.g.dart';

@JsonSerializable()
class StavkeRezervacije {
  int? stavkeRezervacijeId;
  int? uslugaId;
  int? rezervacijaId;
  double? cijena;

  StavkeRezervacije({
    this.stavkeRezervacijeId,
    this.uslugaId,
    this.rezervacijaId,
    this.cijena,
  });
   factory StavkeRezervacije.fromJson(Map<String, dynamic> json) =>
      _$StavkeRezervacijeFromJson(json);

  Map<String, dynamic> toJson() => _$StavkeRezervacijeToJson(this);
}