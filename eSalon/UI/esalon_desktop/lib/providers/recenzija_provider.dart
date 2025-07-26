import 'package:esalon_desktop/models/recenzija.dart';
import 'package:esalon_desktop/providers/base_provider.dart';

class RecenzijaProvider extends BaseProvider<Recenzija> {
  RecenzijaProvider() : super("Recenzija");

  @override
  Recenzija fromJson(data) {
    return Recenzija.fromJson(data);
  }
}