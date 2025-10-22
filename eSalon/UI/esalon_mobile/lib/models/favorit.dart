import 'package:json_annotation/json_annotation.dart';

part 'favorit.g.dart';

@JsonSerializable()
class Favorit {
  int? favoritId;
  int? korisnikId;
  int? uslugaId;
  DateTime? datumDodavanja;
  String? uslugaNaziv;
  double? cijena;
  String? slika; 
  int? trajanje;

  Favorit(
    this.favoritId,
    this.korisnikId,
    this.uslugaId,
    this.datumDodavanja,
    this.uslugaNaziv,
    this.cijena,
    this.slika,
    this.trajanje,
  );

  factory Favorit.fromJson(Map<String, dynamic> json) => _$FavoritFromJson(json);

  Map<String, dynamic> toJson() => _$FavoritToJson(this);
}
