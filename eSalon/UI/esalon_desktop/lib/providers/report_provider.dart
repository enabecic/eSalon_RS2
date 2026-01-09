import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';

class ReportProvider with ChangeNotifier {
  static String? baseUrl;
  String _endpoint = "";

  ReportProvider() {
    _endpoint = "Report";
    baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5224/api/",
    );
  }

  Future<List<int>> getFrizerStatistikaPdf({String? stateMachine}) async {
    var url = "$baseUrl$_endpoint/frizer-statistika-pdf";
    if (stateMachine != null && stateMachine.isNotEmpty) {
      url += "?stateMachine=$stateMachine";
    }
    var uri = Uri.parse(url);

    var headers = createHeaders()
      ..addAll({'Accept': 'application/pdf'});

    try {
      var response = await http.get(uri, headers: headers);
      if (!isValidResponse(response)) {
        throw UserException("Greška pri preuzimanju PDF izvještaja.");
      }
      return response.bodyBytes;
    } catch (e) {
      if (e is UserException) {
        rethrow;
      } else {
        throw UserException(
          "Greška pri preuzimanju PDF izvještaja: ${e.toString()}",
        );
      }
    }
  }

  Future<List<int>> getAdminStatistikaPdf({String? stateMachine}) async {
    var url = "$baseUrl$_endpoint/admin-statistika-pdf";
    if (stateMachine != null && stateMachine.isNotEmpty) {
      url += "?stateMachine=$stateMachine";
    }
    var uri = Uri.parse(url);

    var headers = createHeaders()
      ..addAll({'Accept': 'application/pdf'});

    try {
      var response = await http.get(uri, headers: headers);
      if (!isValidResponse(response)) {
        throw UserException("Greška pri preuzimanju PDF izvještaja.");
      }
      return response.bodyBytes;
    } catch (e) {
      if (e is UserException) {
        rethrow;
      } else {
        throw UserException(
          "Greška pri preuzimanju PDF izvještaja: ${e.toString()}",
        );
      }
    }
  }

  Future<List<int>> getFrizerKreiranPdf({ required int frizerId, required String plainPassword,}) async {
    var url ="$baseUrl$_endpoint/frizer-kreiran-pdf?frizerId=$frizerId&plainPassword=${Uri.encodeComponent(plainPassword)}";
    var uri = Uri.parse(url);

    var headers = createHeaders()
      ..addAll({'Accept': 'application/pdf'});

    try {
      var response = await http.get(uri, headers: headers);
      if (!isValidResponse(response)) {
        throw UserException("Greška pri preuzimanju PDF izvještaja.");
      }
      return response.bodyBytes;
    } catch (e) {
      if (e is UserException) {
        rethrow;
      } else {
        throw UserException(
          "Greška pri preuzimanju PDF izvještaja: ${e.toString()}",
        );
      }
    }
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    }

    if (response.statusCode == 403) {
      throw UserException("Nemate dozvolu za pristup.");
    }

    if (response.statusCode == 401) {
      throw UserException("Neautorizovan pristup.");
    }

    final parsedJson = tryParseJson(response.body);
    if (parsedJson != null &&
        parsedJson['errors'] != null &&
        parsedJson['errors']['userError'] != null) {
      final errors = parsedJson['errors']['userError'];
      if (errors is List) {
        throw UserException(errors.join(', '));
      }
    }

    if (response.body.contains("UserException:")) {
      final msg = response.body.split("UserException:").last.split("\n").first.trim();
      throw UserException(msg);
    }

    throw UserException("Greška u komunikaciji sa serverom.");
  }

  Map<String, dynamic>? tryParseJson(String source) {
    try {
      return jsonDecode(source);
    } catch (_) {
      return null;
    }
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";
    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };

    return headers;
  }
}

class UserException implements Exception {
  final String message;
  UserException(this.message);

  @override
  String toString() => message;
}
