import 'dart:convert';

import 'package:esalon_mobile/models/recenzija.dart';
import 'package:esalon_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RecenzijaProvider extends BaseProvider<Recenzija> {
  RecenzijaProvider() : super("Recenzija");

  @override
  Recenzija fromJson(data) {
    return Recenzija.fromJson(data);
  }

  
  Future<void> toggleLike(int recenzijaId, int korisnikId) async {
    var url = "${BaseProvider.baseUrl}Recenzija/ToggleLike/$recenzijaId/$korisnikId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Greška prilikom lajkanja recenzije");
    }
  }

  Future<void> toggleDislike(int recenzijaId, int korisnikId) async {
    var url = "${BaseProvider.baseUrl}Recenzija/ToggleDislike/$recenzijaId/$korisnikId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Greška prilikom dislajkanja recenzije");
    }
  }

  Future<Map<int, bool?>> getReakcijeKorisnika(int korisnikId, int uslugaId) async {
    var url = "${BaseProvider.baseUrl}Recenzija/ReakcijeKorisnika/$korisnikId/$uslugaId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Greška prilikom dohvaćanja reakcija");
    }

    final Map<String, dynamic> json = jsonDecode(response.body);

    return json.map(
      (key, value) => MapEntry(int.parse(key), value as bool?), 
    );
  }

}