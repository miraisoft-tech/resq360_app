import 'package:resq360/__lib.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
    required this.icon,
    required this.onTap,
    super.key,
  });
  final String icon;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: icon.imageAsset(height: 40, width: 40),
    );
  }
}
