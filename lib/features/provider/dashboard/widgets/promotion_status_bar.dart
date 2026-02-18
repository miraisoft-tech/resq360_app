import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/app_color_theme.dart';

class PromotionStatusBadge extends StatelessWidget {
  const PromotionStatusBadge({
    required this.status,
    required this.isActive,
    super.key,
  });
  final String status;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final badgeData = _getBadgeData(status, isActive, colors);

    return Container(
      padding: pad(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeData.bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: GenText(
        badgeData.displayText,
        size: 11,
        weight: FontWeight.w600,
        color: badgeData.textColor,
      ),
    );
  }

  _BadgeData _getBadgeData(
    String status,
    bool isActive,
    AppColorPalette colors,
  ) {
    if (!isActive) {
      return _BadgeData(
        bgColor: colors.neutral.shade100,
        textColor: colors.neutral.shade700,
        displayText: 'Paused',
      );
    }

    switch (status.toUpperCase()) {
      case 'APPROVED':
        return _BadgeData(
          bgColor: colors.success.shade50,
          textColor: colors.success.shade700,
          displayText: 'Active',
        );
      case 'PENDING':
        return _BadgeData(
          bgColor: colors.warning.shade50,
          textColor: colors.warning.shade700,
          displayText: 'Pending',
        );
      case 'REJECTED':
        return _BadgeData(
          bgColor: colors.error.shade50,
          textColor: colors.error.shade700,
          displayText: 'Rejected',
        );
      default:
        return _BadgeData(
          bgColor: colors.neutral.shade100,
          textColor: colors.neutral.shade700,
          displayText: status,
        );
    }
  }
}

class _BadgeData {
  _BadgeData({
    required this.bgColor,
    required this.textColor,
    required this.displayText,
  });
  final Color bgColor;
  final Color textColor;
  final String displayText;
}
