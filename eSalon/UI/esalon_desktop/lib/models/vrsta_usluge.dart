import 'package:json_annotation/json_annotation.dart';

part 'vrsta_usluge.g.dart';

@JsonSerializable()
class VrstaUsluge {
  int? vrstaId;
  String? naziv;
  String? slika;

  VrstaUsluge({
    this.vrstaId,
    this.naziv,
    this.slika,
  });

  factory VrstaUsluge.fromJson(Map<String, dynamic> json) =>
      _$VrstaUslugeFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$VrstaUslugeToJson(this);

}