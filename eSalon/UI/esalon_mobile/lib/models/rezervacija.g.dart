// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rezervacija.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rezervacija _$RezervacijaFromJson(Map<String, dynamic> json) => Rezervacija(
      rezervacijaId: (json['rezervacijaId'] as num?)?.toInt(),
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      frizerId: (json['frizerId'] as num?)?.toInt(),
      sifra: json['sifra'] as String?,
      datumRezervacije: json['datumRezervacije'] == null
          ? null
          : DateTime.parse(json['datumRezervacije'] as String),
      vrijemePocetka: json['vrijemePocetka'] as String?,
      vrijemeKraja: json['vrijemeKraja'] as String?,
      terminZatvoren: json['terminZatvoren'] as bool?,
      ukupnaCijena: (json['ukupnaCijena'] as num?)?.toDouble(),
      ukupnoTrajanje: (json['ukupnoTrajanje'] as num?)?.toInt(),
      ukupanBrojUsluga: (json['ukupanBrojUsluga'] as num?)?.toInt(),
      stateMachine: json['stateMachine'] as String?,
      nacinPlacanjaId: (json['nacinPlacanjaId'] as num?)?.toInt(),
      aktiviranaPromocijaId: (json['aktiviranaPromocijaId'] as num?)?.toInt(),
      aktiviranaPromocijaNaziv: json['aktiviranaPromocijaNaziv'] as String?,
      frizerImePrezime: json['frizerImePrezime'] as String?,
      klijentImePrezime: json['klijentImePrezime'] as String?,
      nacinPlacanjaNaziv: json['nacinPlacanjaNaziv'] as String?,
      stavkeRezervacijes: (json['stavkeRezervacijes'] as List<dynamic>?)
          ?.map((e) => StavkeRezervacije.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RezervacijaToJson(Rezervacija instance) =>
    <String, dynamic>{
      'rezervacijaId': instance.rezervacijaId,
      'korisnikId': instance.korisnikId,
      'frizerId': instance.frizerId,
      'sifra': instance.sifra,
      'datumRezervacije': instance.datumRezervacije?.toIso8601String(),
      'vrijemePocetka': instance.vrijemePocetka,
      'vrijemeKraja': instance.vrijemeKraja,
      'terminZatvoren': instance.terminZatvoren,
      'ukupnaCijena': instance.ukupnaCijena,
      'ukupnoTrajanje': instance.ukupnoTrajanje,
      'ukupanBrojUsluga': instance.ukupanBrojUsluga,
      'stateMachine': instance.stateMachine,
      'nacinPlacanjaId': instance.nacinPlacanjaId,
      'aktiviranaPromocijaId': instance.aktiviranaPromocijaId,
      'aktiviranaPromocijaNaziv': instance.aktiviranaPromocijaNaziv,
      'frizerImePrezime': instance.frizerImePrezime,
      'klijentImePrezime': instance.klijentImePrezime,
      'nacinPlacanjaNaziv': instance.nacinPlacanjaNaziv,
      'stavkeRezervacijes': instance.stavkeRezervacijes,
    };
