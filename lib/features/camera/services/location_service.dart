import 'package:geolocator/geolocator.dart';

/// Gets the current GPS position
class LocationService {
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
