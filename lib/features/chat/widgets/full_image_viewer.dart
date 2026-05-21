import 'package:resq360/__lib.dart';
import 'package:resq360/features/chat/widgets/chat_image_loader.dart';

class FullImageViewer extends StatelessWidget {
  const FullImageViewer({required this.imageUrl, super.key});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          forceMaterialTransparency: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: ChatImageLoader(
            source: imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
