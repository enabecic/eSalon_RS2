// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vrsta_usluge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VrstaUsluge _$VrstaUslugeFromJson(Map<String, dynamic> json) => VrstaUsluge(
      vrstaId: (json['vrstaId'] as num?)?.toInt(),
      naziv: json['naziv'] as String?,
      slika: json['slika'] as String?,
    );

Map<String, dynamic> _$VrstaUslugeToJson(VrstaUsluge instance) =>
    <String, dynamic>{
      'vrstaId': instance.vrstaId,
      'naziv': instance.naziv,
      'slika': instance.slika,
    };
