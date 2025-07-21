// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stavke_rezervacije.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StavkeRezervacije _$StavkeRezervacijeFromJson(Map<String, dynamic> json) =>
    StavkeRezervacije(
      stavkeRezervacijeId: (json['stavkeRezervacijeId'] as num?)?.toInt(),
      uslugaId: (json['uslugaId'] as num?)?.toInt(),
      rezervacijaId: (json['rezervacijaId'] as num?)?.toInt(),
      cijena: (json['cijena'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StavkeRezervacijeToJson(StavkeRezervacije instance) =>
    <String, dynamic>{
      'stavkeRezervacijeId': instance.stavkeRezervacijeId,
      'uslugaId': instance.uslugaId,
      'rezervacijaId': instance.rezervacijaId,
      'cijena': instance.cijena,
    };
