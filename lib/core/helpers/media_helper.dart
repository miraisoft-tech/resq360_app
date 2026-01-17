import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resq360/__lib.dart';

class MediaPickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<File?> pickImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          if (context.mounted) {
            await showErrorSnackbar(context, 'Camera permission denied');
          }
          return null;
        }
      } else {
        PermissionStatus photosStatus;

        if (Platform.isIOS) {
          photosStatus = await Permission.photos.request();
        } else {
          if (Platform.isAndroid) {
            if (await Permission.storage.isGranted) {
              photosStatus = await Permission.storage.request();
            } else {
              photosStatus = await Permission.mediaLibrary.request();
            }
          } else {
            photosStatus = await Permission.storage.request();
          }
        }

        if (!photosStatus.isGranted) {
          if (context.mounted) {
            await showErrorSnackbar(context, 'Gallery permission denied');
          }
          return null;
        }
      }

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } on Exception catch (e) {
      log('Error picking image: $e');
      if (context.mounted) {
        await showErrorSnackbar(context, 'Failed to pick image');
      }
      return null;
    }
  }

 static Future<File?> pickDocument({
  required BuildContext context,
  List<String>? allowedExtensions,
}) async {
  try {


    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;

    if (file.path == null) return null;

    return File(file.path!);

  } on Exception catch (e) {
    log('Error picking document: $e');
    if (context.mounted) {
      await showErrorSnackbar(context, 'Failed to pick document');
    }
    return null;
  }
}


  static Future<LocationData?> getCurrentLocation({
    required BuildContext context,
  }) async {
    try {
      
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          await showErrorSnackbar(
            context,
            'Location services are disabled. Please enable them.',
          );
        }
        return null;
      }

      
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            await showErrorSnackbar(context, 'Location permission denied');
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          await showErrorSnackbar(
            context,
            'Location permissions are permanently denied',
          );
        }
        return null;
      }

     
      if (context.mounted) {
        showLoadingDialog(context);
      }

     
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

     
      var address = 'Unknown location';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = [
            place.street,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        }
      } on Exception catch (e) {
        log('Geocoding error: $e');
      }

      
      if (context.mounted) {
        Navigator.pop(context);
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } on Exception catch (e) {
      log('Error getting location: $e');
      if (context.mounted) {
        Navigator.pop(context); 
        await showErrorSnackbar(context, 'Failed to get location: $e');
      }
      return null;
    }
  }


  static Future<File?> showImageSourceDialog({
    required BuildContext context,
  }) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const GenText('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const GenText('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const GenText('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    return pickImage(context: context, source: source);
  }
}

class LocationData {
  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;
}
