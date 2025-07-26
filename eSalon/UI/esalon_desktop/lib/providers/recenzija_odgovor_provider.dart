import 'package:esalon_desktop/models/recenzija_odgovor.dart';
import 'package:esalon_desktop/providers/base_provider.dart';

class RecenzijaOdgovorProvider extends BaseProvider<RecenzijaOdgovor> {
  RecenzijaOdgovorProvider() : super("RecenzijaOdgovor");

  @override
  RecenzijaOdgovor fromJson(data) {
    return RecenzijaOdgovor.fromJson(data);
  }
}