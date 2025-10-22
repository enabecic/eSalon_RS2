// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usluga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usluga _$UslugaFromJson(Map<String, dynamic> json) => Usluga(
      uslugaId: (json['uslugaId'] as num?)?.toInt(),
      naziv: json['naziv'] as String?,
      opis: json['opis'] as String?,
      cijena: (json['cijena'] as num?)?.toDouble(),
      trajanje: (json['trajanje'] as num?)?.toInt(),
      slika: json['slika'] as String?,
      datumObjavljivanja: json['datumObjavljivanja'] as String?,
      vrstaId: (json['vrstaId'] as num?)?.toInt(),
      vrstaUslugeNaziv: json['vrstaUslugeNaziv'] as String?,
    );

Map<String, dynamic> _$UslugaToJson(Usluga instance) => <String, dynamic>{
      'uslugaId': instance.uslugaId,
      'naziv': instance.naziv,
      'opis': instance.opis,
      'cijena': instance.cijena,
      'trajanje': instance.trajanje,
      'slika': instance.slika,
      'datumObjavljivanja': instance.datumObjavljivanja,
      'vrstaId': instance.vrstaId,
      'vrstaUslugeNaziv': instance.vrstaUslugeNaziv,
    };
