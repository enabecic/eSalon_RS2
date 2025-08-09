import 'package:esalon_desktop/models/arhiva.dart';
import 'package:esalon_desktop/providers/base_provider.dart';

class ArhivaProvider extends BaseProvider<Arhiva> {
  ArhivaProvider() : super("Arhiva");

  @override
  Arhiva fromJson(data) {
    return Arhiva.fromJson(data);
  }
}
