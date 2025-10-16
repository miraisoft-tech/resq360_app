import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:resq360/__lib.dart';

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

  Future<Placemark> _getAddressFromCoords() async {
    if (currentPosition == null) {
      throw Exception('Current position is null');
    }

    final placemarks = await placemarkFromCoordinates(
      currentPosition!.latitude,
      currentPosition!.longitude,
    );

    final place = placemarks.first;
    log('Address: ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}, ${place.postalCode}');
    notifyListeners();
    return place;
  }

  @protected
  void onLocationUpdated() {}
}
