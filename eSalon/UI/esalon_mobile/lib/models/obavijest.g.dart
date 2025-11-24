// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'obavijest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Obavijest _$ObavijestFromJson(Map<String, dynamic> json) => Obavijest(
      (json['obavijestId'] as num?)?.toInt(),
      (json['korisnikId'] as num).toInt(),
      json['naslov'] as String,
      json['sadrzaj'] as String,
      DateTime.parse(json['datumObavijesti'] as String),
      json['jePogledana'] as bool,
      json['imePrezime'] as String?,
    );

Map<String, dynamic> _$ObavijestToJson(Obavijest instance) => <String, dynamic>{
      'obavijestId': instance.obavijestId,
      'korisnikId': instance.korisnikId,
      'naslov': instance.naslov,
      'sadrzaj': instance.sadrzaj,
      'datumObavijesti': instance.datumObavijesti.toIso8601String(),
      'jePogledana': instance.jePogledana,
      'imePrezime': instance.imePrezime,
    };
