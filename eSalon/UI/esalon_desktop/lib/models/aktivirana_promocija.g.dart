// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aktivirana_promocija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AktiviranaPromocija _$AktiviranaPromocijaFromJson(Map<String, dynamic> json) =>
    AktiviranaPromocija(
      aktiviranaPromocijaId: (json['aktiviranaPromocijaId'] as num?)?.toInt(),
      promocijaId: (json['promocijaId'] as num?)?.toInt(),
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      aktivirana: json['aktivirana'] as bool?,
      iskoristena: json['iskoristena'] as bool?,
      datumAktiviranja: json['datumAktiviranja'] == null
          ? null
          : DateTime.parse(json['datumAktiviranja'] as String),
      promocijaNaziv: json['promocijaNaziv'] as String?,
      korisnikImePrezime: json['korisnikImePrezime'] as String?,
      kodPromocije: json['kodPromocije'] as String?,
      slikaUsluge: json['slikaUsluge'] as String?,
      popust: (json['popust'] as num?)?.toDouble(),
      datumPocetka: json['datumPocetka'] == null
          ? null
          : DateTime.parse(json['datumPocetka'] as String),
      datumKraja: json['datumKraja'] == null
          ? null
          : DateTime.parse(json['datumKraja'] as String),
    );

Map<String, dynamic> _$AktiviranaPromocijaToJson(
        AktiviranaPromocija instance) =>
    <String, dynamic>{
      'aktiviranaPromocijaId': instance.aktiviranaPromocijaId,
      'promocijaId': instance.promocijaId,
      'korisnikId': instance.korisnikId,
      'aktivirana': instance.aktivirana,
      'iskoristena': instance.iskoristena,
      'datumAktiviranja': instance.datumAktiviranja?.toIso8601String(),
      'promocijaNaziv': instance.promocijaNaziv,
      'korisnikImePrezime': instance.korisnikImePrezime,
      'kodPromocije': instance.kodPromocije,
      'slikaUsluge': instance.slikaUsluge,
      'popust': instance.popust,
      'datumPocetka': instance.datumPocetka?.toIso8601String(),
      'datumKraja': instance.datumKraja?.toIso8601String(),
    };
