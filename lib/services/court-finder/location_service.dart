import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  double calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // in km
  }

  String formatDistance(double? distanceKm) {
    if (distanceKm == null) return '';

    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)}m';
    } else {
      return '${distanceKm.toStringAsFixed(1)}km';
    }
  }
}