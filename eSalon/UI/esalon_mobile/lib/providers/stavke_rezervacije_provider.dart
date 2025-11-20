
import 'package:esalon_mobile/models/stavke_rezervacije.dart';
import 'package:esalon_mobile/providers/base_provider.dart';

class StavkeRezervacijeProvider extends BaseProvider<StavkeRezervacije> {
  StavkeRezervacijeProvider() : super("StavkeRezervacije");

  @override
  StavkeRezervacije fromJson(data) {
    return StavkeRezervacije.fromJson(data);
  }
}