import 'package:json_annotation/json_annotation.dart';

part 'stavke_rezervacije.g.dart';

@JsonSerializable()
class StavkeRezervacije {
  int? stavkeRezervacijeId;
  int? uslugaId;
  int? rezervacijaId;
  double? cijena;
  String? uslugaNaziv;
  int? trajanje;
  double? originalnaCijena;
  bool? imaPopust;
  String? slika; 

  StavkeRezervacije({
    this.stavkeRezervacijeId,
    this.uslugaId,
    this.rezervacijaId,
    this.cijena,
    this.uslugaNaziv,
    this.trajanje,
    this.originalnaCijena,
    this.imaPopust,
    this.slika,
  });

  factory StavkeRezervacije.fromJson(Map<String, dynamic> json) =>
      _$StavkeRezervacijeFromJson(json);

  Map<String, dynamic> toJson() => _$StavkeRezervacijeToJson(this);
}