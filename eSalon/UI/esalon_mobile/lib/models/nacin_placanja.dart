import 'package:json_annotation/json_annotation.dart';

part 'nacin_placanja.g.dart';

@JsonSerializable()
class NacinPlacanja {
  int? nacinPlacanjaId;
  String? naziv;

  NacinPlacanja({
    this.nacinPlacanjaId,
    this.naziv,
  });

  factory NacinPlacanja.fromJson(Map<String, dynamic> json) =>
      _$NacinPlacanjaFromJson(json);

  Map<String, dynamic> toJson() => _$NacinPlacanjaToJson(this);
}
