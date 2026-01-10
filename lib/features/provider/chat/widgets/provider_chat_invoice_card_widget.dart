import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';
import 'package:resq360/features/provider/chat/data/models/payment_status.enum.dart';


class ProviderChatInvoiceCardWidget extends StatelessWidget {
  const ProviderChatInvoiceCardWidget({
    required this.onTapPay,
    required this.paymentStatus,
    required this.metadata,
    required this.message,
    required this.chat,
    super.key,
  });

  final void Function() onTapPay;
  final PaymentStatus paymentStatus;
  final Metadata metadata;
  final ChatResponse chat;
  final MessageResponse message;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final createdAt = message.createdAt;
    final time = message.createdAt != null ? message.createdAt!.formatDate : '';

    if (message.messageType != 'SYSTEM' ||
        metadata.type != 'INVOICE' ||
        metadata.amount == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: pad(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color:
            paymentStatus == PaymentStatus.completed
                ? const Color(0xFFF0FDF4)
                : appColors.primary.shade500,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Col(
        children: [
          Container(
            padding: pad(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color:
                    paymentStatus == PaymentStatus.completed
                        ? appColors.textColor.shade100
                        : Colors.white,
              ),
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
                          color:
                              paymentStatus == PaymentStatus.completed
                                  ? appColors.success.shade700
                                  : Colors.white,
                          size: 18,
                          height: 20.5,
                          weight: FontWeight.w700,
                        ),
                        4.verticalSpace,
                        GenText(
                          metadata.invoiceId ?? '—',
                          weight: FontWeight.w400,
                          color:
                              paymentStatus == PaymentStatus.completed
                                  ? appColors.textColor.shade300
                                  : Colors.white,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UrbText(
                          'Date',
                          color:
                              paymentStatus == PaymentStatus.completed
                                  ? appColors.success.shade700
                                  : Colors.white,
                          size: 18,
                          height: 20.5,
                          weight: FontWeight.w700,
                        ),
                        2.verticalSpace,
                        GenText(
                          createdAt != null ? createdAt.formatDate : '',
                          weight: FontWeight.w400,
                          color:
                              paymentStatus == PaymentStatus.completed
                                  ? appColors.textColor.shade300
                                  : Colors.white,
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
                          color:
                              paymentStatus == PaymentStatus.completed
                                  ? appColors.success.shade700
                                  : Colors.white,
                          weight: FontWeight.w500,
                        ),
                        2.verticalSpace,
                        GenText(
                          chat.serviceName ?? '-',
                          size: 12,
                          weight: FontWeight.w400,
                          color:
                              paymentStatus == PaymentStatus.completed
                                  ? appColors.textColor.shade300
                                  : Colors.white,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GenText(
                          'Client',
                          color:
                              paymentStatus == PaymentStatus.completed
                                  ? appColors.success.shade700
                                  : Colors.white,
                          weight: FontWeight.w500,
                        ),
                        2.verticalSpace,
                        GenText(
                          chat.user?.fullName ?? '',
                          size: 12,
                          weight: FontWeight.w400,
                          color:
                              paymentStatus == PaymentStatus.completed
                                  ? appColors.textColor.shade300
                                  : Colors.white,
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
                        color:
                            paymentStatus == PaymentStatus.completed
                                ? appColors.success.shade700
                                : Colors.white,
                        weight: FontWeight.w500,
                      ),
                      4.horizontalSpace,
                      AppAssets.ASSETS_ICONS_ARROW_DROPDOWN_SVG.svgColor(
                        color:
                            paymentStatus == PaymentStatus.completed
                                ? appColors.success.shade700
                                : Colors.white,
                      ),
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
                      color:
                          paymentStatus == PaymentStatus.completed
                              ? appColors.textColor.shade400
                              : Colors.white,
                    ),
                    GenText(
                      metadata.amount?.toString() ?? '0',
                      size: 16,
                      weight: FontWeight.w700,
                      color:
                          paymentStatus == PaymentStatus.completed
                              ? appColors.success.shade700
                              : Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          16.verticalSpace,
          UrbText(
            paymentStatus == PaymentStatus.completed
                ? 'Payment Confirmed'
                : 'Pending Payment...',
            size: 16,
            height: 26.5,
            weight: FontWeight.w700,
            color:
                paymentStatus == PaymentStatus.completed
                    ? appColors.success.shade700
                    : Colors.white,
          ),
          6.verticalSpace,
          GenText(
            time,
            size: 12,
            color:
                paymentStatus == PaymentStatus.completed
                    ? appColors.textColor.shade300
                    : Colors.white,
          ),
        ],
      ),
    );
  }
}
