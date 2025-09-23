import 'dart:io' as io;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http_package;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resq360/__lib.dart';
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

  static Future<io.File?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        withData: true,
        allowedExtensions: ['jpg', 'pdf', 'doc', 'docx'],
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
}
