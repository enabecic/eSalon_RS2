import 'package:esalon_desktop/models/uloga.dart';
import 'package:esalon_desktop/providers/base_provider.dart';

class UlogaProvider extends BaseProvider<Uloga> {
  UlogaProvider() : super("Uloga");

  @override
  Uloga fromJson(data) {
    return Uloga.fromJson(data);
  }
}