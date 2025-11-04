import 'package:json_annotation/json_annotation.dart';

part 'aktivirana_promocija.g.dart';

@JsonSerializable()
class AktiviranaPromocija {
  int? aktiviranaPromocijaId;
  int? promocijaId;
  int? korisnikId;
  bool? aktivirana;
  bool? iskoristena;
  DateTime? datumAktiviranja;
  String? promocijaNaziv;
  String? korisnikImePrezime;
  String? kodPromocije;
  String? slikaUsluge; 
  double? popust;
  DateTime? datumPocetka;
  DateTime? datumKraja;

  AktiviranaPromocija({
    this.aktiviranaPromocijaId,
    this.promocijaId,
    this.korisnikId,
    this.aktivirana,
    this.iskoristena,
    this.datumAktiviranja,
    this.promocijaNaziv,
    this.korisnikImePrezime,
    this.kodPromocije,
    this.slikaUsluge,
    this.popust,
    this.datumPocetka,
    this.datumKraja,
  });

  factory AktiviranaPromocija.fromJson(Map<String, dynamic> json) =>
      _$AktiviranaPromocijaFromJson(json);

  Map<String, dynamic> toJson() => _$AktiviranaPromocijaToJson(this);
}
