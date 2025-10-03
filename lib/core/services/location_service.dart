import 'dart:async';
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
    log('Location fetched successfully!');

    notifyListeners();
    onLocationUpdated();
  }

  @protected
  void onLocationUpdated() {}
}
