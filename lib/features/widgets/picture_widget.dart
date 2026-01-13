import 'package:resq360/__lib.dart';

class PictureWidget extends StatelessWidget {
  const PictureWidget({this.image, this.radius = 25, super.key});

  final String? image;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage:
          image != null
              ? NetworkImage(image!)
              : const AssetImage(
                    AppAssets.ASSETS_IMAGES_GENERIC_ICON_PNG,
                  )
                  as ImageProvider,
    );
  }
}
