import 'package:esalon_mobile/models/promocija.dart';
import 'package:esalon_mobile/providers/base_provider.dart';

class PromocijaProvider extends BaseProvider<Promocija> {
  PromocijaProvider() : super("Promocija");

  @override
  Promocija fromJson(data) {
    return Promocija.fromJson(data);
  }
}