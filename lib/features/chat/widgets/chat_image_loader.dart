import 'dart:io';
import 'package:flutter/material.dart';

class ChatImageLoader extends StatelessWidget {
  const ChatImageLoader({
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;

  bool get _isLocal =>
      source.startsWith('/') || source.startsWith('file://');

  @override
  Widget build(BuildContext context) {
    return _isLocal ? _buildLocal() : _buildNetwork();
  }

  Widget _buildLocal() {
    return Image.file(
      File(source),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _errorPlaceholder(),
    );
  }

  Widget _buildNetwork() {
    return Image.network(
      source,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          color: Colors.black12,
          child: const CircularProgressIndicator(),
        );
      },
      errorBuilder: (_, _, _) => _errorPlaceholder(),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: Colors.black12,
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 40,
      ),
    );
  }
}
