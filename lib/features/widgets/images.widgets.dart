import 'dart:io' as io;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:resq360/__lib.dart';

Widget boxedImage({
  required String imgUrl,
  required Color boxColor,
  EdgeInsetsGeometry? padding,
  double imgSize = 24,
}) {
  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: boxColor,
      borderRadius: BorderRadius.circular(3),
    ),
    child: assetsImage(imgUrl: imgUrl, height: imgSize, width: imgSize),
  );
}

Widget assetsImage({
  required String imgUrl,
  BoxFit? fit,
  BoxShape shape = BoxShape.rectangle,
  double? height = 24,
  double? width = 24,
  double? both,
  Key? key,
  AlignmentGeometry? alignment,
}) => Container(
  alignment: alignment,
  key: key,
  height: both?.h ?? height?.h,
  width: both?.w ?? width?.w,
  padding: EdgeInsets.zero,
  margin: EdgeInsets.zero,
  decoration: BoxDecoration(
    shape: shape,
    image: DecorationImage(image: AssetImage(imgUrl), fit: fit),
  ),
);

Widget ioFileImage({
  required io.File imageFile,
  BoxFit? fit,
  BoxShape shape = BoxShape.rectangle,
  double? height = 24,
  double? width = 24,
  double? both,
}) => Container(
  height: both ?? height,
  width: both ?? width,
  decoration: BoxDecoration(
    shape: shape,
    image: DecorationImage(image: FileImage(imageFile), fit: fit),
  ),
);

Widget memoryImage({
  required Uint8List imgBytes,
  BoxFit? fit,
  BoxShape shape = BoxShape.rectangle,
  double? height = 24,
  double? width = 24,
  double? both,
}) => Container(
  height: both ?? height,
  width: both ?? width,
  decoration: BoxDecoration(
    shape: shape,
    image: DecorationImage(image: MemoryImage(imgBytes), fit: fit),
  ),
);

class CacheNetworkImageWidget extends StatelessWidget {
  const CacheNetworkImageWidget({
    required this.imgUrl,
    this.fit,
    this.shape = BoxShape.rectangle,
    this.height,
    this.width,
    this.both,
    this.colorFilter,
    super.key,
  });
  final String imgUrl;
  final BoxFit? fit;
  final BoxShape shape;
  final double? height;
  final double? width;
  final double? both;
  final ColorFilter? colorFilter;

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.network(
      imgUrl,
      height: both ?? height,
      width: both ?? width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        log('---Image.network----url: $imgUrl -----error: $error ------');
        return assetsImage(
          imgUrl: '', //AppAssets.ASSETS_LOGO_LOGO_PNG,
          shape: shape,
          both: both,
          height: height,
          width: width,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CupertinoActivityIndicator());
      },
      colorBlendMode: BlendMode.srcIn,
    );

    if (shape == BoxShape.circle) {
      return ClipOval(child: imageWidget);
    } else {
      return imageWidget;
    }

    // return CachedNetworkImage(
    //   imageUrl: imgUrl,
    //   height: both ?? height,
    //   width: both ?? width,
    //   imageBuilder: (
    //     BuildContext context,
    //     ImageProvider<Object> imageProvider,
    //   ) {
    //     return Container(
    //       decoration: BoxDecoration(
    //         shape: shape,
    //         image: DecorationImage(
    //           image: imageProvider,
    //           colorFilter: colorFilter,
    //           fit: fit,
    //         ),
    //       ),
    //     );
    //   },
    //   placeholder:
    //       (BuildContext context, String url) =>
    //           const Center(child: CupertinoActivityIndicator()),
    //   errorWidget: (BuildContext context, String url, dynamic error) {
    //     log('---cacheNetworkImage----url: $url -----error: $error ------');
    //     return assetsImage(
    //       imgUrl: AppAssets.ASSETS_LOGO_LOGO_PNG,
    //       shape: shape,
    //       both: both,
    //       height: height,
    //       width: width,
    //     );
    //   },
    // );
  }
}
