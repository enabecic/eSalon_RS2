// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arhiva.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Arhiva _$ArhivaFromJson(Map<String, dynamic> json) => Arhiva(
      (json['arhivaId'] as num?)?.toInt(),
      (json['korisnikId'] as num?)?.toInt(),
      (json['uslugaId'] as num?)?.toInt(),
      json['datumDodavanja'] == null
          ? null
          : DateTime.parse(json['datumDodavanja'] as String),
      json['uslugaNaziv'] as String?,
      (json['cijena'] as num?)?.toDouble(),
      json['slika'] as String?,
      (json['trajanje'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ArhivaToJson(Arhiva instance) => <String, dynamic>{
      'arhivaId': instance.arhivaId,
      'korisnikId': instance.korisnikId,
      'uslugaId': instance.uslugaId,
      'datumDodavanja': instance.datumDodavanja?.toIso8601String(),
      'uslugaNaziv': instance.uslugaNaziv,
      'cijena': instance.cijena,
      'slika': instance.slika,
      'trajanje': instance.trajanje,
    };
