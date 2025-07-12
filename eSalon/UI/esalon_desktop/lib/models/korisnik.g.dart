// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korisnik.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Korisnik _$KorisnikFromJson(Map<String, dynamic> json) => Korisnik()
  ..korisnikId = (json['korisnikId'] as num?)?.toInt()
  ..ime = json['ime'] as String?
  ..prezime = json['prezime'] as String?
  ..korisnickoIme = json['korisnickoIme'] as String?
  ..email = json['email'] as String?
  ..telefon = json['telefon'] as String?
  ..jeAktivan = json['jeAktivan'] as bool?
  ..datumRegistracije = json['datumRegistracije'] == null
      ? null
      : DateTime.parse(json['datumRegistracije'] as String)
  ..uloge = (json['uloge'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..slika = json['slika'] as String?;

Map<String, dynamic> _$KorisnikToJson(Korisnik instance) => <String, dynamic>{
      'korisnikId': instance.korisnikId,
      'ime': instance.ime,
      'prezime': instance.prezime,
      'korisnickoIme': instance.korisnickoIme,
      'email': instance.email,
      'telefon': instance.telefon,
      'jeAktivan': instance.jeAktivan,
      'datumRegistracije': instance.datumRegistracije?.toIso8601String(),
      'uloge': instance.uloge,
      'slika': instance.slika,
    };
