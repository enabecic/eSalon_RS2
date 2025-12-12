// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nacin_placanja.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NacinPlacanja _$NacinPlacanjaFromJson(Map<String, dynamic> json) =>
    NacinPlacanja(
      nacinPlacanjaId: (json['nacinPlacanjaId'] as num?)?.toInt(),
      naziv: json['naziv'] as String?,
    );

Map<String, dynamic> _$NacinPlacanjaToJson(NacinPlacanja instance) =>
    <String, dynamic>{
      'nacinPlacanjaId': instance.nacinPlacanjaId,
      'naziv': instance.naziv,
    };
