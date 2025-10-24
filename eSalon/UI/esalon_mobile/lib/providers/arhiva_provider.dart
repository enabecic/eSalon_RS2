import 'package:esalon_mobile/models/arhiva.dart';
import 'package:esalon_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class ArhivaProvider extends BaseProvider<Arhiva> {
  ArhivaProvider() : super("Arhiva");

  @override
  Arhiva fromJson(data) {
    return Arhiva.fromJson(data);
  }

  Future<int> getBrojArhiviranja(int uslugaId) async {
    var url = "${BaseProvider.baseUrl}Arhiva/BrojArhiviranja/$uslugaId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.get(uri, headers: headers);

      if (!isValidResponse(response)) {
        throw UserException("Greška prilikom dohvatanja broja arhiviranja.");
      }

      return int.parse(response.body);
    } catch (e) {
      if (e is UserException) rethrow;
      throw UserException(
          "Greška prilikom dohvatanja broja arhiviranja: ${e.toString()}");
    }
  }

}