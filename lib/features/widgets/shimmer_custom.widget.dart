import 'package:resq360/__lib.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget.rectangular({
    required this.height,
    super.key,
    this.width = double.infinity,
  }) : borderShape = const RoundedRectangleBorder();

  const ShimmerWidget.circular({
    required this.width,
    required this.height,
    super.key,
    this.borderShape = const CircleBorder(),
  });
  final double width;
  final double height;
  final ShapeBorder borderShape;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          shape: borderShape,
          color: Colors.grey[300],
        ),
      ),
    );
  }
}
