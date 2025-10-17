import 'dart:convert';
import 'package:esalon_mobile/models/search_result.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? baseUrl;
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    baseUrl = const String.fromEnvironment("baseUrl",
        //defaultValue: "http://localhost:5224/api/");
        defaultValue: "http://10.0.2.2:5224/api/");
  }

  Future<SearchResult<T>> get(
      {dynamic filter,
      int? page,
      int? pageSize,
      String? orderBy,
      String? sortDirection,
      bool? isDeleted}) async {

    var url = "$baseUrl$_endpoint";

    Map<String, dynamic> queryParams = {};
    if (filter != null) {
      queryParams.addAll(filter);
    }
    if (page != null) {
      queryParams['page'] = page;
    }
    if (pageSize != null) {
      queryParams['pageSize'] = pageSize;
    }
    if (orderBy != null) {
      queryParams['orderBy'] = orderBy;
    }
    if (sortDirection != null) {
      queryParams['sortDirection'] = sortDirection;
    }
    if (isDeleted != null) {
      queryParams['isDeleted'] = isDeleted;
    }
    if (queryParams.isNotEmpty) {
      var queryString = getQueryString(queryParams);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
    
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<T>();

      result.count = data['count'];

      for (var item in data['resultList']) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception("Nepoznata greška");
    }
    // print("response: ${response.request} ${response.statusCode}, ${response.body}");
  }

    Future<T> getById(int id) async {
    var url = "$baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future delete(int id) async {
    var url = "$baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      return;
    } else {
      throw Exception("Nepoznata greška");
    }
  }

  Future<T> insert(dynamic request) async {
    var url = "$baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Nepoznata greška");
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Nepoznata greška");
    }
  }

  T fromJson(data) {
    throw Exception("Metoda nije implementirana");
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
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

  // Map<String, String> createHeaders() {
  //   final headers = {"Content-Type": "application/json"};

  //   if (AuthProvider.username != null && AuthProvider.username!.isNotEmpty &&
  //       AuthProvider.password != null && AuthProvider.password!.isNotEmpty) {
  //     final basicAuth =
  //         "Basic ${base64Encode(utf8.encode('${AuthProvider.username}:${AuthProvider.password}'))}";
  //     headers["Authorization"] = basicAuth;
  //   }

  //   return headers;
  // }

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

  String getQueryString(Map params,
      {String prefix = '&', bool inRecursion = false}) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${(value as DateTime).toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query +=
              getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });
    return query;
  }
}

class UserException implements Exception {
  final String exMessage;

  UserException(this.exMessage);

  @override
  String toString() => exMessage;
}