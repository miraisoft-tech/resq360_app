import 'dart:io' as io;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http_package;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/location_data.dart';
export 'package:image_picker/image_picker.dart';

class AppFilePicker {
  //
  static Future<CroppedFile?> cropImage(io.File imageFile) async {
    return ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '',
          toolbarWidgetColor: Colors.black,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: '',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );
  }

  static Future<io.File?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final picker = ImagePicker();

      final result = await picker.pickImage(source: source);

      if (result != null) {
        final selectedFile = result;

        final crop = await cropImage(io.File(selectedFile.path));

        // io.File compressedFile = await FlutterNativeImage.compressImage(
        //   crop!.path,
        //   percentage: 100,
        //   quality: 100,
        //   targetHeight: 150,
        //   targetWidth: 150,
        // );

        return io.File(crop!.path);
      } else {
        return null;
      }
    } on Exception catch (e) {
      log(e);

      return null;
    }
  }

  static Future<List<io.File>?> pickMultiImages({int limit = 3}) async {
    try {
      final picker = ImagePicker();

      final result = await picker.pickMultiImage(
        imageQuality: 100,
        maxHeight: 1000,
        maxWidth: 1000,
        limit: limit,
      );

      if (result.isNotEmpty) {
        final selectedFiles = <io.File>[];

        for (final file in result) {
          final crop = await cropImage(io.File(file.path));

          // io.File compressedFile = await FlutterNativeImage.compressImage(
          //   crop!.path,
          //   percentage: 100,
          //   quality: 100,
          //   targetHeight: 150,
          //   targetWidth: 150,
          // );

          selectedFiles.add(io.File(crop!.path));
        }

        return selectedFiles;
      } else {
        return null;
      }
    } on Exception catch (e) {
      log(e);

      return null;
    }
  }

  static Future<File> downloadImage(String imageUrl) async {
    final url = Uri.parse(imageUrl);
    final response = await http_package.get(url);

    if (response.statusCode == 200) {
      final appDir = await getTemporaryDirectory();
      final file = File('${appDir.path}/temp_image.jpg');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Failed to download image');
    }
  }

  static Future<io.File?> pickDocumentZ({
    required BuildContext context,
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        final platFormFile = result.files.first;

        final uint8list = platFormFile.bytes!;
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/${platFormFile.name}')
          ..writeAsBytesSync(uint8list);
        //convert platform to file

        // print(file.name);
        // print(file.bytes);
        // print(file.size);
        // print(file.extension);
        // print(file.path);

        return file;
      } else {
        return null;
      }
    } on Exception catch (e) {
      log(e);

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
}
