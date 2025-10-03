import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter/services.dart';
import 'package:resq360/features/widgets/snackbar.dart';

class AppClipBoardUtil {
  static Future<void> copyString(
    BuildContext context, {
    required String content,
    String successMessage = 'Copied to clipboard',
  }) async {
    final data = ClipboardData(text: content);
    await showSuccessSnackbar(context, successMessage);
    await Clipboard.setData(data);
  }
}
