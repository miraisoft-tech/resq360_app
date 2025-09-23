import 'package:resq360/__lib.dart';

class ListDivider extends ConsumerWidget {
  const ListDivider({
    super.key,
    this.verticalSpacing = 24,
    this.thickness = 1,
    this.color,
  });
  final double verticalSpacing;
  final double thickness;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: pad(vertical: verticalSpacing),
      child: Container(
        height: thickness,
        color: color ?? const Color.fromRGBO(226, 226, 226, 1),
      ),
    );
  }
}
