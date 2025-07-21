import 'package:esalon_desktop/models/vrsta_usluge.dart';
import 'package:esalon_desktop/providers/base_provider.dart';

class VrstaUslugeProvider extends BaseProvider<VrstaUsluge> {
  VrstaUslugeProvider() : super("VrstaUsluge");

  @override
  VrstaUsluge fromJson(data) {
    return VrstaUsluge.fromJson(data);
  }
}
