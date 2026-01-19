import 'package:flutter/material.dart';
import 'package:resq360/core/extensions/theme_extension.dart';
import 'package:resq360/features/widgets/buttons.widgets.dart';

class ErrorMessageAndButton extends StatelessWidget {
  const ErrorMessageAndButton({
    required this.error,
    super.key,
    this.onPressed,
  });
  final String error;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            error,
            style: TextStyle(color: colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(8),
            child: WideButton(label: 'Retry', onPressed: onPressed),
          ),
        ],
      ),
    );
  }
}
