import 'package:esalon_desktop/models/usluga.dart';
import 'package:esalon_desktop/providers/base_provider.dart';

class UslugaProvider extends BaseProvider<Usluga> {
  UslugaProvider() : super("Usluga");

  @override
  Usluga fromJson(data) {
    return Usluga.fromJson(data);
  }
}
