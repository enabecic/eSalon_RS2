// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recenzija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recenzija _$RecenzijaFromJson(Map<String, dynamic> json) => Recenzija(
      (json['recenzijaId'] as num?)?.toInt(),
      (json['korisnikId'] as num).toInt(),
      (json['uslugaId'] as num).toInt(),
      json['komentar'] as String,
      DateTime.parse(json['datumDodavanja'] as String),
      (json['brojLajkova'] as num).toInt(),
      (json['brojDislajkova'] as num).toInt(),
      json['korisnickoIme'] as String?,
      json['nazivUsluge'] as String?,
      (json['brojOdgovora'] as num).toInt(),
      json['jeLajkOdKorisnika'] as bool,
      json['jeDislajkOdKorisnika'] as bool,
    );

Map<String, dynamic> _$RecenzijaToJson(Recenzija instance) => <String, dynamic>{
      'recenzijaId': instance.recenzijaId,
      'korisnikId': instance.korisnikId,
      'uslugaId': instance.uslugaId,
      'komentar': instance.komentar,
      'datumDodavanja': instance.datumDodavanja.toIso8601String(),
      'brojLajkova': instance.brojLajkova,
      'brojDislajkova': instance.brojDislajkova,
      'korisnickoIme': instance.korisnickoIme,
      'nazivUsluge': instance.nazivUsluge,
      'brojOdgovora': instance.brojOdgovora,
      'jeLajkOdKorisnika': instance.jeLajkOdKorisnika,
      'jeDislajkOdKorisnika': instance.jeDislajkOdKorisnika,
    };
