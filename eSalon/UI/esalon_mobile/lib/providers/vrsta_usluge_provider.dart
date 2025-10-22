import 'package:esalon_mobile/models/vrsta_usluge.dart';
import 'package:esalon_mobile/providers/base_provider.dart';

class VrstaUslugeProvider extends BaseProvider<VrstaUsluge> {
  VrstaUslugeProvider() : super("VrstaUsluge");

  @override
  VrstaUsluge fromJson(data) {
    return VrstaUsluge.fromJson(data);
  }
}