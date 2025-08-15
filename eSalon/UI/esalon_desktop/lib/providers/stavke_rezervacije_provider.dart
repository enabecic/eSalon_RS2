
import 'package:esalon_desktop/models/stavke_rezervacije.dart';
import 'package:esalon_desktop/providers/base_provider.dart';

class StavkeRezervacijeProvider extends BaseProvider<StavkeRezervacije> {
  StavkeRezervacijeProvider() : super("StavkeRezervacije");

  @override
  StavkeRezervacije fromJson(data) {
    return StavkeRezervacije.fromJson(data);
  }
}