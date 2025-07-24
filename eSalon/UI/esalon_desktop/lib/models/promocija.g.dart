// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promocija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Promocija _$PromocijaFromJson(Map<String, dynamic> json) => Promocija(
      promocijaId: (json['promocijaId'] as num?)?.toInt(),
      naziv: json['naziv'] as String?,
      opis: json['opis'] as String?,
      kod: json['kod'] as String?,
      popust: (json['popust'] as num?)?.toDouble(),
      datumPocetka: json['datumPocetka'] == null
          ? null
          : DateTime.parse(json['datumPocetka'] as String),
      datumKraja: json['datumKraja'] == null
          ? null
          : DateTime.parse(json['datumKraja'] as String),
      uslugaId: (json['uslugaId'] as num?)?.toInt(),
      uslugaNaziv: json['uslugaNaziv'] as String?,
      slikaUsluge: json['slikaUsluge'] as String?,
      status: json['status'] as bool?,
    );

Map<String, dynamic> _$PromocijaToJson(Promocija instance) => <String, dynamic>{
      'promocijaId': instance.promocijaId,
      'naziv': instance.naziv,
      'opis': instance.opis,
      'kod': instance.kod,
      'popust': instance.popust,
      'datumPocetka': instance.datumPocetka?.toIso8601String(),
      'datumKraja': instance.datumKraja?.toIso8601String(),
      'uslugaId': instance.uslugaId,
      'uslugaNaziv': instance.uslugaNaziv,
      'slikaUsluge': instance.slikaUsluge,
      'status': instance.status,
    };
