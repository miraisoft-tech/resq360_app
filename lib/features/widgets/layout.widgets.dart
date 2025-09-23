import 'package:resq360/__lib.dart';

class Col extends StatelessWidget {
  const Col({required this.children, super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

EdgeInsets pad({double both = 0, double? horizontal, double? vertical}) =>
    EdgeInsets.symmetric(
      horizontal: horizontal ?? both,
      vertical: vertical ?? both,
    );
