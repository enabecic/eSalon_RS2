import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:esalon_mobile/models/rezervacija.dart';
import 'package:esalon_mobile/providers/base_provider.dart';

class RezervacijaProvider extends BaseProvider<Rezervacija> {
  RezervacijaProvider() : super("Rezervacija");

  @override
  Rezervacija fromJson(data) {
    return Rezervacija.fromJson(data);
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

  Future<List<Map<String, String>>> getKalendar({ required int frizerId, required int godina, required int mjesec, }) async {
    var url = "${BaseProvider.baseUrl}Rezervacija/kalendar?frizerId=$frizerId&godina=$godina&mjesec=$mjesec";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body) as List<dynamic>;

      return data.map<Map<String, String>>((d) {
        return {
          'datum': d['datum'] ?? '',
          'status': d['status'] ?? 'slobodan',
        };
      }).toList();
    } else {
      throw UserException("Greška pri učitavanju kalendara.");
    }
  }

  Future<List<Map<String, String>>> getZauzetiTermini({ required int frizerId, required DateTime datumRezervacije,}) async {
    final url = "${BaseProvider.baseUrl}Rezervacija/zauzeti-termini?frizerId=$frizerId&datumRezervacije=${datumRezervacije.toIso8601String()}";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map<Map<String, String>>((d) {
        return {
          'vrijemePocetka': d['vrijemePocetka'],
          'vrijemeKraja': d['vrijemeKraja'],
        };
      }).toList();
    } else {
      throw UserException("Greška pri učitavanju zauzetih termina.");
    }
  }

  Future<void> provjeriTermin(Map<String, dynamic> request) async {
    final url = "${BaseProvider.baseUrl}Rezervacija/provjeri-termin";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final body = jsonEncode(request);

    final response = await http.post(uri, headers: headers, body: body);

    if (isValidResponse(response)) {
      return; 
    } else {
      var data = jsonDecode(response.body);
      throw UserException(data['message'] ?? "Termin nije dostupan.");
    }
  }

}