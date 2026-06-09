import 'package:geolocator/geolocator.dart';

class LocationService {
  // Default = Merzouga, Southeast Morocco
  static const double defaultLat = 31.0800;
  static const double defaultLng = -4.0100;

  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }
}