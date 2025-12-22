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

    var response = await http.get(uri, headers: headers);
    if (response.body.isEmpty || response.body == 'null') {
      return [];
    }
    if (isValidResponse(response)) {
      var data = json.decode(response.body);

      if (data is List) {
        List<Usluga> dataList =
            data.map((item) => Usluga.fromJson(item)).toList();
        return dataList;
      } else {
        throw UserException("Greška");
      }
    }
    throw UserException("Greška");
  }

}