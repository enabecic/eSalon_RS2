import 'package:esalon_desktop/models/promocija.dart';
import 'package:esalon_desktop/providers/base_provider.dart';

class PromocijaProvider extends BaseProvider<Promocija> {
  PromocijaProvider() : super("Promocija");

  @override
  Promocija fromJson(data) {
    return Promocija.fromJson(data);
  }
}
