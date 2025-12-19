import 'dart:convert';

import 'package:esalon_mobile/models/recenzija_odgovor.dart';
import 'package:esalon_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RecenzijaOdgovorProvider extends BaseProvider<RecenzijaOdgovor> {
  RecenzijaOdgovorProvider() : super("RecenzijaOdgovor");

  @override
  RecenzijaOdgovor fromJson(data) {
    return RecenzijaOdgovor.fromJson(data);
  }

  Future<void> toggleLike(int recenzijaOdgovorId, int korisnikId) async {
    var url = "${BaseProvider.baseUrl}RecenzijaOdgovor/ToggleLike/$recenzijaOdgovorId/$korisnikId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Greška prilikom lajkanja odgovora na recenziju");
    }
  }

  Future<void> toggleDislike(int recenzijaOdgovorId, int korisnikId) async {
    var url = "${BaseProvider.baseUrl}RecenzijaOdgovor/ToggleDislike/$recenzijaOdgovorId/$korisnikId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Greška prilikom dislajkanja odgovora na recenziju");
    }
  }

  Future<Map<int, bool?>> getReakcijeKorisnika(int korisnikId, int recenzijaId) async {
    var url = "${BaseProvider.baseUrl}RecenzijaOdgovor/ReakcijeKorisnika/$korisnikId/$recenzijaId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Greška prilikom dohvaćanja reakcija odgovora");
    }

    final Map<String, dynamic> json = jsonDecode(response.body);

    return json.map(
      (key, value) => MapEntry(int.parse(key), value as bool?),
    );
  }

}