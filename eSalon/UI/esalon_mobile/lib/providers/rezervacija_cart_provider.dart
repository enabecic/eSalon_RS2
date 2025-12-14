import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esalon_mobile/models/usluga.dart';

class RezervacijaCartProvider with ChangeNotifier {
  final int? userId;
  static const String _cartKeyPrefix = 'rezervacija_';
  int? _popustUslugaId;
  double _popustIznos = 0.0;
  int? get popustUslugaId => _popustUslugaId;
  double get popustIznos => _popustIznos;

  RezervacijaCartProvider(this.userId);

  Map<String, dynamic> _uslugaToMap(Usluga usluga) {
    return {
      'id': usluga.uslugaId,
      'naziv': usluga.naziv,
      'opis': usluga.opis,
      'vrstaId': usluga.vrstaId,
      'vrstaUslugeNaziv': usluga.vrstaUslugeNaziv,
      'slika': usluga.slika,
      'datumObjavljivanja': usluga.datumObjavljivanja,
      'cijena': usluga.cijena,
      'trajanje': usluga.trajanje,
    };
  }

  Future<void> addToRezervacijaList(Usluga usluga) async {
    final prefs = await SharedPreferences.getInstance();
    final cartKey = '$_cartKeyPrefix$userId';
    Map<String, dynamic> lista = {};

    if (prefs.containsKey(cartKey)) {
      final String data = prefs.getString(cartKey)!;
      try {
        lista = Map<String, dynamic>.from(json.decode(data));
      } catch (_) {}
    }

    String uslugaId = usluga.uslugaId.toString();
    if (!lista.containsKey(uslugaId)) {
      lista[uslugaId] = _uslugaToMap(usluga);
      await prefs.setString(cartKey, json.encode(lista));
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getRezervacijaList() async {
    final prefs = await SharedPreferences.getInstance();
    final cartKey = '$_cartKeyPrefix$userId';
    if (prefs.containsKey(cartKey)) {
      final String data = prefs.getString(cartKey)!;
      try {
        return Map<String, dynamic>.from(json.decode(data));
      } catch (_) {}
    }
    return {};
  }

  Future<void> removeUsluga(int uslugaId) async {
    final prefs = await SharedPreferences.getInstance();
    final cartKey = '$_cartKeyPrefix$userId';
    Map<String, dynamic> lista = {};

    if (prefs.containsKey(cartKey)) {
      final String data = prefs.getString(cartKey)!;
      try {
        lista = Map<String, dynamic>.from(json.decode(data));
      } catch (_) {}
    }

    if (lista.containsKey(uslugaId.toString())) {
      lista.remove(uslugaId.toString());
      await prefs.setString(cartKey, json.encode(lista));
      notifyListeners();
    }
  }

  Future<void> clearRezervacijaList() async {
    final prefs = await SharedPreferences.getInstance();
    final cartKey = '$_cartKeyPrefix$userId';
    await prefs.remove(cartKey);
    notifyListeners();
  }

  Future<bool> isInRezervacija(int uslugaId) async {
    final lista = await getRezervacijaList();
    return lista.containsKey(uslugaId.toString());
  }

  Future<void> primijeniPopust({ required int uslugaId, required double popust, }) async {
    _popustUslugaId = uslugaId;
    _popustIznos = popust;
    notifyListeners();
  }

  void ukloniPopust() {
    _popustUslugaId = null;
    _popustIznos = 0.0;
    notifyListeners();
  }

  Future<double> izracunajUkupnuCijenu() async {
    final lista = await getRezervacijaList(); 
    double total = 0.0;

    for (var u in lista.values) {
      double cijena = (u['cijena'] as num).toDouble();

      if (_popustUslugaId != null && u['id'] == _popustUslugaId) {
        cijena = cijena - (cijena * _popustIznos / 100);
      }
      total += cijena;
    }
    return total;
  }

}