import 'dart:math';
import 'package:burn_tech/models/art_model.dart';
import 'package:geolocator/geolocator.dart';

class TravelTimeService {
  static const double _walkingSpeed = 83.33; // ~5 km/h
  static const double _cyclingSpeed = 250.0; // ~15 km/h
  static const double _drivingSpeed = 667.0; // ~40 km/h

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // Earth's radius in meters
    final double phi1 = lat1 * pi / 180;
    final double phi2 = lat2 * pi / 180;
    final double deltaPhi = (lat2 - lat1) * pi / 180;
    final double deltaLambda = (lon2 - lon1) * pi / 180;

    final double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<Position> _getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> getTravelTime(ArtModel art, String mode) async {
    if (art.location?.gpsLatitude == null || art.location?.gpsLongitude == null) {
      return "Unknown";
    }

    try {
      final Position currentPosition = await _getCurrentPosition();
      final double distance = _calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        art.location!.gpsLatitude!,
        art.location!.gpsLongitude!,
      );

      double speed;
      switch (mode.toLowerCase()) {
        case "walking":
          speed = _walkingSpeed;
          break;
        case "cycling":
          speed = _cyclingSpeed;
          break;
        case "driving":
          speed = _drivingSpeed;
          break;
        default:
          return "Invalid mode";
      }

      return "${(distance / speed).round()} min";
    } catch (e) {
      return "Unknown";
    }
  }
}