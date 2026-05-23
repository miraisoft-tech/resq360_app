import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/chat/data/models/chat_response.dart';

class DisputeServiceDetailCard extends StatelessWidget {
  const DisputeServiceDetailCard({
    required this.chat,
    this.isCollapsed = false,
    this.onToggle,
    super.key,
  });

  final ChatResponse chat;
  final bool isCollapsed;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final requestId = chat.serviceRequestId;
    final createdAt =
        chat.createdAt != null
            ? AppTextUtil.formatChatTime(chat.createdAt!.toLocal())
            : '';

    final summary = [
      if (requestId != null) '#$requestId',
      if (chat.serviceName != null) chat.serviceName!,
    ].join(' • ');

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      padding: pad(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: appColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.textColor.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenText(
                      'Service Detail',
                      weight: FontWeight.w600,
                      color: appColors.black,
                      size: 15,
                    ),
                    if (isCollapsed && summary.isNotEmpty) ...[
                      3.verticalSpace,
                      GenText(
                        summary,
                        color: appColors.textColor.shade400,
                        size: 12,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
              if (onToggle != null)
                IconButton(
                  constraints: BoxConstraints.tight(Size(32.w, 32.h)),
                  padding: EdgeInsets.zero,
                  onPressed: onToggle,
                  icon: Icon(
                    isCollapsed
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: appColors.textColor.shade500,
                  ),
                ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child:
                isCollapsed
                    ? const SizedBox.shrink()
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        12.verticalSpace,
                        if (requestId != null)
                          DetailRow(label: 'Service ID:', value: '#$requestId'),
                        if (chat.serviceName != null)
                          DetailRow(
                            label: 'Service:',
                            value: chat.serviceName!,
                          ),
                        DetailRow(label: 'Date & Time:', value: createdAt),
                        if (chat.provider?.fullName != null)
                          DetailRow(
                            label: 'Provider:',
                            value: chat.provider!.fullName!,
                          ),
                        if (chat.user?.fullName != null)
                          DetailRow(
                            label: 'Client:',
                            value: chat.user!.fullName!,
                          ),
                        8.verticalSpace,
                        GenText(
                          createdAt,
                          size: 12,
                          color: appColors.textColor.shade300,
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({required this.label, required this.value, super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GenText(label, color: appColors.textColor.shade400, size: 13),
          6.horizontalSpace,
          Expanded(
            child: GenText(
              value,
              color: appColors.textColor.shade400,
              size: 13,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
