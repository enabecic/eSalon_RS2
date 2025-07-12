import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String formatNumber(dynamic) {
  var f = NumberFormat('###,##0.00', 'de_DE');
  if (dynamic == null) {
    return "";
  }
  return f.format(dynamic);
}

Image imageFromString(String input) {
  return Image.memory(base64Decode(input));
}

String formatDate(String date) {
  return DateFormat('dd.MM.yyyy').format(DateTime.parse(date).toLocal());
}

String formatDateTime(String date) {
  return DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(date).toLocal());
}
