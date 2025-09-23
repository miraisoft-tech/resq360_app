import 'package:flutter/services.dart';
import 'package:resq360/features/widgets/snackbar.dart';

class AppClipBoardUtil {
  static Future<void> copyString({
    required String content,
    String successMessage = 'Copied to clipboard',
  }) async {
    final data = ClipboardData(text: content);
    await showSuccessSnackbar(successMessage);
    await Clipboard.setData(data);
  }
}
