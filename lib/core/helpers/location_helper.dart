import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;

class LocationHelper {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await geo.Geolocator.openLocationSettings();
      throw Exception('Location services are disabled');
    }

    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }
    if (permission == geo.LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    final position = await geo.Geolocator.getCurrentPosition(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final place = placemarks.first;

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'city': place.locality ?? '',
      'state': place.administrativeArea ?? '',
      'zipCode': place.postalCode ?? '',
      'address': place.street ?? '',
      'country': place.country ?? '',
    };
  }
}
