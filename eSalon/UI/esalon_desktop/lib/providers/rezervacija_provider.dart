import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:esalon_desktop/models/rezervacija.dart';
import 'package:esalon_desktop/providers/base_provider.dart';

class RezervacijaProvider extends BaseProvider<Rezervacija> {
  RezervacijaProvider() : super("Rezervacija");

  @override
  Rezervacija fromJson(data) {
    return Rezervacija.fromJson(data);
  }

  Future<Rezervacija> odobri(int rezervacijaId, int frizerId) async {
    var url = "${BaseProvider.baseUrl}Rezervacija/$rezervacijaId/odobri/$frizerId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw UserException("Greška pri odobravanju rezervacije.");
    }
  }

  Future<Rezervacija> zavrsi(int rezervacijaId) async {
    var url = "${BaseProvider.baseUrl}Rezervacija/$rezervacijaId/zavrsi";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw UserException("Greška pri završavanju rezervacije.");
    }
  }
  Future<Rezervacija> ponisti(int rezervacijaId) async {
    var url = "${BaseProvider.baseUrl}Rezervacija/$rezervacijaId/ponisti";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw UserException("Greška pri poništavanju rezervacije.");
    }
  }

}
