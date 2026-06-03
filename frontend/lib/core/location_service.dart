import 'package:geolocator/geolocator.dart';

class AppLocation {
  const AppLocation(this.latitude, this.longitude, {this.isFallback = false});
  final double latitude;
  final double longitude;
  final bool isFallback;
}

class LocationService {
  static const AppLocation fallback = AppLocation(-6.2219000, 106.6479000, isFallback: true);

  Future<AppLocation?> current({bool allowFallback = true}) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return allowFallback ? fallback : null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return allowFallback ? fallback : null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );
      return AppLocation(position.latitude, position.longitude);
    } catch (_) {
      return allowFallback ? fallback : null;
    }
  }
}
