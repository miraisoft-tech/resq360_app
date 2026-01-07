import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_response.dart';
import 'package:resq360/features/customer/chat/data/models/chat/message_response.dart';
import 'package:resq360/features/customer/chat/data/models/chat/metadata.dart';

class ChatInvoiceCardWidget extends StatelessWidget {
  const ChatInvoiceCardWidget({
    required this.onTapPay,
    required this.metadata,
    required this.messageCreatedAt,
    required this.message, 
    required this.chat,
    super.key, 
  });

  final void Function() onTapPay;
  final Metadata metadata;
  final MessageResponse message;
  final ChatResponse chat;
  final String messageCreatedAt;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UrbText(
                    'Invoice No.',
                    color: appColors.black,
                    size: 18,
                    height: 20.5,
                    weight: FontWeight.w700,
                  ),
                  4.verticalSpace,
                  GenText(
                    metadata.invoiceId ?? '—',
                    weight: FontWeight.w400,
                    color: appColors.textColor.shade300,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UrbText(
                    'Date',
                    color: appColors.black,
                    size: 18,
                    height: 20.5,
                    weight: FontWeight.w700,
                  ),
                  2.verticalSpace,
                  GenText(
                    chat.createdAt?.formatDate ?? '—',
                    weight: FontWeight.w400,
                    color: appColors.textColor.shade300,
                  ),
                ],
              ),
            ],
          ),
          16.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenText(
                    'Service Provider',
                    color: appColors.black,
                    weight: FontWeight.w500,
                  ),
                  2.verticalSpace,
                  GenText(
                    chat.serviceName ?? '—',
                    size: 12,
                    weight: FontWeight.w400,
                    color: appColors.textColor.shade300,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenText(
                    'Client',
                    color: appColors.black,
                    weight: FontWeight.w500,
                  ),
                  2.verticalSpace,
                  GenText(
                   chat.user?.fullName ?? '',
                    size: 12,
                    weight: FontWeight.w400,
                    color: appColors.textColor.shade300,
                  ),
                ],
              ),
            ],
          ),
          12.verticalSpace,
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                GenText(
                  'View More Details',
                  color: appColors.primary,
                  weight: FontWeight.w500,
                ),
                4.horizontalSpace,
                AppAssets.ASSETS_ICONS_ARROW_DROPDOWN_SVG.svg,
              ],
            ),
          ),
          16.verticalSpace,
          Divider(color: appColors.textColor.shade100),
          12.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GenText(
                'Total Amount',
                color: appColors.textColor.shade400,
              ),
              GenText(
                metadata.amount?.toString() ?? '0',
                size: 16,
                weight: FontWeight.w700,
                color: appColors.black,
              ),
            ],
          ),
          16.verticalSpace,
          WideButton(
            label: 'Pay Now',
            onPressed: onTapPay,
          ),
          6.verticalSpace,
          GenText(
            messageCreatedAt,
            size: 12,
            color: appColors.textColor.shade300,
          ),
        ],
      ),
    );
  }
}
