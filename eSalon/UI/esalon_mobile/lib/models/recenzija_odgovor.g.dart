// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recenzija_odgovor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecenzijaOdgovor _$RecenzijaOdgovorFromJson(Map<String, dynamic> json) =>
    RecenzijaOdgovor(
      (json['recenzijaOdgovorId'] as num?)?.toInt(),
      (json['recenzijaId'] as num).toInt(),
      (json['korisnikId'] as num).toInt(),
      json['komentar'] as String,
      DateTime.parse(json['datumDodavanja'] as String),
      (json['brojLajkova'] as num).toInt(),
      (json['brojDislajkova'] as num).toInt(),
      json['korisnickoIme'] as String?,
      json['komentarRecenzije'] as String?,
      json['nazivUsluge'] as String?,
    );

Map<String, dynamic> _$RecenzijaOdgovorToJson(RecenzijaOdgovor instance) =>
    <String, dynamic>{
      'recenzijaOdgovorId': instance.recenzijaOdgovorId,
      'recenzijaId': instance.recenzijaId,
      'korisnikId': instance.korisnikId,
      'komentar': instance.komentar,
      'datumDodavanja': instance.datumDodavanja.toIso8601String(),
      'brojLajkova': instance.brojLajkova,
      'brojDislajkova': instance.brojDislajkova,
      'korisnickoIme': instance.korisnickoIme,
      'komentarRecenzije': instance.komentarRecenzije,
      'nazivUsluge': instance.nazivUsluge,
    };
