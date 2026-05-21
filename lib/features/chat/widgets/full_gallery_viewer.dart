import 'package:resq360/__lib.dart';
import 'package:resq360/features/chat/widgets/chat_image_loader.dart';

class FullGalleryViewer extends StatelessWidget {
  const FullGalleryViewer({required this.images, super.key});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          forceMaterialTransparency: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        itemCount: images.length,
        itemBuilder: (_, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: ChatImageLoader(
              source: images[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
