import 'package:resq360/__lib.dart';

class SettingsItem {
  SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final VoidCallback onTap;
}
