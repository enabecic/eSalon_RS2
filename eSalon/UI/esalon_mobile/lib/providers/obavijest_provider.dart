import 'package:esalon_mobile/models/obavijest.dart';
import 'package:esalon_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class ObavijestProvider extends BaseProvider<Obavijest> {
  ObavijestProvider() : super("Obavijest");

  @override
  Obavijest fromJson(data) {
    return Obavijest.fromJson(data);
  }

  Future<void> oznaciKaoProcitanu(int obavijestId) async {
    var url = "${BaseProvider.baseUrl}Obavijest/OznaciKaoProcitanu/$obavijestId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.put(uri, headers: headers);

      if (!isValidResponse(response)) {
        throw UserException("Greška prilikom označavanja obavijesti kao pročitane.");
      }
    } catch (e) {
      if (e is UserException) {
        rethrow;
      }
      throw UserException("Greška prilikom označavanja obavijesti: ${e.toString()}");
    }
  }

}