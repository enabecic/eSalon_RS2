// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arhiva.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Arhiva _$ArhivaFromJson(Map<String, dynamic> json) => Arhiva(
      arhivaId: (json['arhivaId'] as num?)?.toInt(),
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      uslugaId: (json['uslugaId'] as num?)?.toInt(),
      datumDodavanja: json['datumDodavanja'] == null
          ? null
          : DateTime.parse(json['datumDodavanja'] as String),
      uslugaNaziv: json['uslugaNaziv'] as String?,
      cijena: (json['cijena'] as num?)?.toDouble(),
      slika: json['slika'] as String?,
      trajanje: (json['trajanje'] as num?)?.toInt(),
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
