
import 'package:location/location.dart';

requestLocationService() async {
  Location location = new Location();
  return await location.requestService();
}