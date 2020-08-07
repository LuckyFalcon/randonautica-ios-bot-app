
import 'package:location/location.dart';

getLocation() async {
  Location location = new Location();
  await location.requestService();

  return await location.getLocation();
}