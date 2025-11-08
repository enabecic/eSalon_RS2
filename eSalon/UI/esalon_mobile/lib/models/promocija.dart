import 'package:json_annotation/json_annotation.dart';

part 'promocija.g.dart';

@JsonSerializable()
class Promocija {
  int? promocijaId;
  String? naziv;
  String? opis;
  String? kod;
  double? popust;
  DateTime? datumPocetka;
  DateTime? datumKraja;
  int? uslugaId;
  String? uslugaNaziv;
  String? slikaUsluge;
  bool? status;
  bool? jeBuduca;

  Promocija({
    this.promocijaId,
    this.naziv,
    this.opis,
    this.kod,
    this.popust,
    this.datumPocetka,
    this.datumKraja,
    this.uslugaId,
    this.uslugaNaziv,
    this.slikaUsluge,
    this.status,
    this.jeBuduca,
  });

  factory Promocija.fromJson(Map<String, dynamic> json) =>
      _$PromocijaFromJson(json);
  Map<String, dynamic> toJson() => _$PromocijaToJson(this);
}

