import 'package:esalon_desktop/models/aktivirana_promocija.dart';
import 'package:esalon_desktop/providers/base_provider.dart';

class AktiviranaPromocijaProvider extends BaseProvider<AktiviranaPromocija> {
  AktiviranaPromocijaProvider() : super("AktiviranaPromocija");

  @override
  AktiviranaPromocija fromJson(data) {
    return AktiviranaPromocija.fromJson(data);
  }
}
