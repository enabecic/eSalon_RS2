import 'package:esalon_mobile/models/favorit.dart';
import 'package:esalon_mobile/providers/base_provider.dart';

class FavoritProvider extends BaseProvider<Favorit> {
  FavoritProvider() : super("Favorit");

  @override
  Favorit fromJson(data) {
    return Favorit.fromJson(data);
  }
}