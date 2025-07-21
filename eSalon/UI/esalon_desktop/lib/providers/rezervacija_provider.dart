//import 'package:http/http.dart' as http;
import 'package:esalon_desktop/models/rezervacija.dart';
import 'package:esalon_desktop/providers/base_provider.dart';

class RezervacijaProvider extends BaseProvider<Rezervacija> {
  RezervacijaProvider() : super("Rezervacija");

  @override
  Rezervacija fromJson(data) {
    return Rezervacija.fromJson(data);
  }

  //  Future ponisti(int rezervacijaId) async {
  //   var url = "${BaseProvider.baseUrl}Rezervacija/${rezervacijaId}/ponisti"; 
  //   var uri = Uri.parse(url);
  //   var headers = createHeaders();

  //   var response = await http.put(uri, headers: headers);
  // }

}
