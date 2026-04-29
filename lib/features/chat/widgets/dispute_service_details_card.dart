import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/chat/data/models/chat_response.dart';

class DisputeServiceDetailCard extends StatelessWidget {
  const DisputeServiceDetailCard({required this.chat, super.key});
  final ChatResponse chat;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final requestId = chat.serviceRequestId;
    final createdAt =
        chat.createdAt != null
            ? AppTextUtil.formatChatTime(chat.createdAt!.toLocal())
            : '';

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
          GenText(
            'Service Detail',
            weight: FontWeight.w600,
            color: appColors.black,
            size: 15,
          ),
          12.verticalSpace,
          if (requestId != null)
            DetailRow(label: 'Service ID:', value: '#$requestId'),
          if (chat.serviceName != null)
            DetailRow(label: 'Service:', value: chat.serviceName!),
          DetailRow(label: 'Date & Time:', value: createdAt),
          if (chat.provider?.fullName != null)
            DetailRow(label: 'Provider:', value: chat.provider!.fullName!),
          if (chat.user?.fullName != null)
            DetailRow(label: 'Client:', value: chat.user!.fullName!),
          if (chat.paymentInvoiceId != null)
            DetailRow(label: 'Payment:', value: chat.paymentInvoiceId!),
          8.verticalSpace,
          GenText(createdAt, size: 12, color: appColors.textColor.shade300),
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
