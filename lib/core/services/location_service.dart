import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/shared_preferences.dart';

abstract class BaseViewModel extends ChangeNotifier {
  BaseViewModel() {
    onInit();
  }

  @protected
  void onInit() {}
}

mixin LocationMixin on BaseViewModel {
  geo.Position? currentPosition;
   Placemark? currentPlacemark;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initLocation();
  }


  Future<void> _initLocation() async {
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await geo.Geolocator.openLocationSettings();
      return;
    }

    

    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }
    if (permission == geo.LocationPermission.deniedForever) {
      return;
    }

    if (permission != geo.LocationPermission.always &&
        permission != geo.LocationPermission.whileInUse) {
      return;
    }

    const settings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: 100,
    );

    currentPosition = await geo.Geolocator.getCurrentPosition(
      locationSettings: settings,
    );
    currentPlacemark = await _getAddressFromCoords();
    log('Location fetched successfully!');

    notifyListeners();
    onLocationUpdated();
  }

  Future<Placemark?> _getAddressFromCoords() async {
  if (currentPosition == null) {
    throw Exception('Current position is null');
  }
  log('Lat: ${currentPosition!.latitude}, Lng: ${currentPosition!.longitude}');
  await AppLocalPref().save(key: 'latitude', value: currentPosition!.latitude.toString());
  await AppLocalPref().save(key: 'longitude', value: currentPosition!.longitude.toString());

  try {
    final placemarks = await placemarkFromCoordinates(
      currentPosition!.latitude,
      currentPosition!.longitude,
    ).timeout(const Duration(seconds: 5)); // prevent long hangs

    final place = placemarks.first;
    log('Address: ${place.street}, ${place.locality}, ${place.country}');
    notifyListeners();
    return place;
  } on TimeoutException catch (_) {
    log('Reverse geocoding timed out');
    return null;
  } on Exception catch (e) {
    log('Geocoding failed: $e');
    return null;
  }
}

  @protected
  void onLocationUpdated() {}
}
