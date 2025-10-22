import 'package:esalon_mobile/models/ocjena.dart';
import 'package:esalon_mobile/providers/base_provider.dart';

class OcjenaProvider extends BaseProvider<Ocjena> {
  OcjenaProvider() : super("Ocjena");

  @override
  Ocjena fromJson(data) {
    return Ocjena.fromJson(data);
  }
  
}