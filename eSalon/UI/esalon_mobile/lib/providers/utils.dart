import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatNumber(dynamic) {
  var f = NumberFormat('###,##0.00', 'de_DE');
  if (dynamic == null) {
    return "";
  }
  return f.format(dynamic);
}

Image imageFromString(String input) {
  return Image.memory(base64Decode(input),fit: BoxFit.cover,);
}

String formatDate(String date) {
  return DateFormat('dd.MM.yyyy').format(DateTime.parse(date).toLocal());
}

String formatDateTime(String date) {
  return DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(date).toLocal());
}

String formatirajDatum(DateTime? dt) {
  if (dt == null) return "";
  String dan = dt.day.toString().padLeft(2, '0');
  String mjesec = dt.month.toString().padLeft(2, '0');
  String godina = dt.year.toString();
  String sati = dt.hour.toString().padLeft(2, '0');
  String minute = dt.minute.toString().padLeft(2, '0');
  return "$dan.$mjesec.$godina $sati:$minute";
}

String formatirajDatumSaDanom(DateTime dt) {
  const dani = [
    'Ponedjeljak', 'Utorak', 'Srijeda', 'Četvrtak', 'Petak', 'Subota', 'Nedjelja'
  ];
  String danSedmice = dani[dt.weekday - 1];
  String datum = "${dt.day.toString().padLeft(2,'0')}.${dt.month.toString().padLeft(2,'0')}.${dt.year}";
  return "$danSedmice, $datum";
}

String formatTime24(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return "$h:$m";
}
