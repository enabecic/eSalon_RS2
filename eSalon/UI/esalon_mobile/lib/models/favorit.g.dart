// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Favorit _$FavoritFromJson(Map<String, dynamic> json) => Favorit(
      (json['favoritId'] as num?)?.toInt(),
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

Map<String, dynamic> _$FavoritToJson(Favorit instance) => <String, dynamic>{
      'favoritId': instance.favoritId,
      'korisnikId': instance.korisnikId,
      'uslugaId': instance.uslugaId,
      'datumDodavanja': instance.datumDodavanja?.toIso8601String(),
      'uslugaNaziv': instance.uslugaNaziv,
      'cijena': instance.cijena,
      'slika': instance.slika,
      'trajanje': instance.trajanje,
    };
