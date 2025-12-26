import 'package:esalon_mobile/models/usluga.dart';
import 'package:esalon_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UslugaProvider extends BaseProvider<Usluga> {
  UslugaProvider() : super("Usluga");

  @override
  Usluga fromJson(data) {
    return Usluga.fromJson(data);
  }

  Future<List<Usluga>> getRecommendedServices(int uslugaId) async {
    var url = "${BaseProvider.baseUrl}Usluga/$uslugaId/recommended";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.get(uri, headers: headers);

      if (response.body.isEmpty || response.body == 'null') {
        return [];
      }

      if (!isValidResponse(response)) {
        throw UserException("Greška prilikom dohvatanja preporučenih usluga.");
      }

      var data = jsonDecode(response.body);

      if (data is List) {
        return data.map((item) => Usluga.fromJson(item)).toList();
      } else {
        throw UserException("Greška u formatu podataka.");
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw UserException(
          "Greška prilikom dohvatanja preporučenih usluga: ${e.toString()}");
    }
  }

}