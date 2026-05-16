import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/chat/data/models/chat_response.dart';
import 'package:resq360/features/chat/data/models/message_response.dart';
import 'package:resq360/features/chat/widgets/dispute_service_details_card.dart';

class AppealClosedCard extends StatelessWidget {
  const AppealClosedCard({
    required this.message,
    required this.chat,
    super.key,
  });
  final MessageResponse message;
  final ChatResponse chat;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final time = AppTextUtil.formatChatTime(
      message.createdAt?.toLocal() ?? DateTime.now().toLocal(),
    );
    final refundedAmount =
        message.metadata?.customData?['refundedAmount']?.toString() ?? '';
    final requestId = chat.serviceRequestId ?? '';
    final providerName = chat.provider?.fullName ?? '';

    return Container(
      width: double.infinity,
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
              GenText(
                'Appeal closed',
                color: appColors.black,
                size: 13,
                weight: FontWeight.w400,
              ),
            ],
          ),
          12.verticalSpace,
          if (refundedAmount.isNotEmpty)
            DetailRow(label: 'Refunded amount:', value: 'NGN $refundedAmount'),
          DetailRow(label: 'Service ID:', value: '#$requestId'),
          if (providerName.isNotEmpty)
            DetailRow(label: 'Provider:', value: providerName),
          8.verticalSpace,
          GenText(time, size: 12, color: appColors.textColor.shade300),
        ],
      ),
    );
  }
}
