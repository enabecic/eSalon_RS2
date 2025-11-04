import 'package:esalon_mobile/models/aktivirana_promocija.dart';
import 'package:esalon_mobile/providers/base_provider.dart';

class AktiviranaPromocijaProvider extends BaseProvider<AktiviranaPromocija> {
  AktiviranaPromocijaProvider() : super("AktiviranaPromocija");

  @override
  AktiviranaPromocija fromJson(data) {
    return AktiviranaPromocija.fromJson(data);
  }
}