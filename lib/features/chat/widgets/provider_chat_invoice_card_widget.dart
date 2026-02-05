import 'package:resq360/__lib.dart';
import 'package:resq360/core/extensions/invoice_date_formatter.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';

class ProviderChatInvoiceCardWidget extends StatefulWidget {
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
  State<ProviderChatInvoiceCardWidget> createState() =>
      _ProviderChatInvoiceCardWidgetState();
}

class _ProviderChatInvoiceCardWidgetState
    extends State<ProviderChatInvoiceCardWidget> {
  bool viewMore = false;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final time =
        widget.message.createdAt != null
            ? widget.message.createdAt!.formatDate
            : '';
    final date =
        widget.metadata.date != null
            ? widget.metadata.date!.toInvoiceDate()
            : '';

    if (widget.metadata.type != MessageReceivedType.invoice.value ||
        widget.metadata.amount == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: pad(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color:
            widget.paymentStatus == PaymentStatus.completed
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
                    widget.paymentStatus == PaymentStatus.completed
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
                              widget.paymentStatus == PaymentStatus.completed
                                  ? appColors.success.shade700
                                  : Colors.white,
                          size: 18,
                          height: 20.5,
                          weight: FontWeight.w700,
                        ),
                        4.verticalSpace,
                        GenText(
                          widget.metadata.invoiceId ?? '—',
                          weight: FontWeight.w400,
                          color:
                              widget.paymentStatus == PaymentStatus.completed
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
                              widget.paymentStatus == PaymentStatus.completed
                                  ? appColors.success.shade700
                                  : Colors.white,
                          size: 18,
                          height: 20.5,
                          weight: FontWeight.w700,
                        ),
                        2.verticalSpace,
                        GenText(
                          date,
                          weight: FontWeight.w400,
                          color:
                              widget.paymentStatus == PaymentStatus.completed
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
                              widget.paymentStatus == PaymentStatus.completed
                                  ? appColors.success.shade700
                                  : Colors.white,
                          weight: FontWeight.w500,
                        ),
                        2.verticalSpace,
                        GenText(
                          widget.chat.provider?.fullName ?? '-',
                          size: 12,
                          weight: FontWeight.w400,
                          color:
                              widget.paymentStatus == PaymentStatus.completed
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
                              widget.paymentStatus == PaymentStatus.completed
                                  ? appColors.success.shade700
                                  : Colors.white,
                          weight: FontWeight.w500,
                        ),
                        2.verticalSpace,
                        GenText(
                          widget.chat.user?.fullName ?? '',
                          size: 12,
                          weight: FontWeight.w400,
                          color:
                              widget.paymentStatus == PaymentStatus.completed
                                  ? appColors.textColor.shade300
                                  : Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
                12.verticalSpace,
                GestureDetector(
                  onTap: () {
                    setState(() {
                      viewMore = !viewMore;
                    });
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        GenText(
                          viewMore ? 'View Less Details' : 'View More Details',
                          color:
                              widget.paymentStatus == PaymentStatus.completed
                                  ? appColors.success.shade700
                                  : Colors.white,
                          weight: FontWeight.w500,
                        ),
                        4.horizontalSpace,
                        Transform.flip(
                          flipY: viewMore,
                          child: AppAssets.ASSETS_ICONS_ARROW_DROPDOWN_SVG
                              .svgColor(
                                color:
                                    widget.paymentStatus ==
                                            PaymentStatus.completed
                                        ? appColors.success.shade700
                                        : Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                16.verticalSpace,
                if (viewMore)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GenText(
                        'Service Type',
                        weight: FontWeight.w500,
                        color: appColors.success.shade700,
                      ),
                      2.verticalSpace,
                      GenText(
                        widget.chat.serviceName ?? '-',
                        size: 12,
                        color: context.appColors.textColor.shade300,
                      ),
                      10.verticalSpace,
                      GenText(
                        'Description',
                        weight: FontWeight.w500,
                        color: appColors.success.shade700,
                      ),
                      2.verticalSpace,
                      GenText(
                        widget.metadata.description ?? '-',
                        size: 12,
                        color: context.appColors.textColor.shade300,
                      ),
                      if (widget.metadata.date != null) ...[
                         10.verticalSpace,
                        GenText(
                          'Date',
                          weight: FontWeight.w500,
                          color: appColors.success.shade700
                        ),
                        2.verticalSpace,
                        GenText(
                          AppTextUtil.formatDateToString(widget.metadata.date!,),
                          size: 12,
                          color: context.appColors.textColor.shade300,
                        ),
                        10.verticalSpace,
                      ],

                      if (widget.metadata.address != null) ...[
                        GenText(
                          'Location',
                          weight: FontWeight.w500,
                          color: context.appColors.black,
                        ),
                        2.verticalSpace,
                        GenText(
                          widget.metadata.address!,
                          size: 12,
                          color: context.appColors.textColor.shade300,
                        ),
                      ],
                    ],
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
                          widget.paymentStatus == PaymentStatus.completed
                              ? appColors.textColor.shade400
                              : Colors.white,
                    ),
                    GenText(
                      'NGN${AppTextUtil.formatAmount(
                        widget.metadata.amount?.toString() ?? '0',
                      )}',
                      size: 16,
                      weight: FontWeight.w700,
                      color:
                          widget.paymentStatus == PaymentStatus.completed
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
            widget.paymentStatus == PaymentStatus.completed
                ? 'Payment Confirmed'
                : 'Pending Payment...',
            size: 16,
            height: 26.5,
            weight: FontWeight.w700,
            color:
                widget.paymentStatus == PaymentStatus.completed
                    ? appColors.success.shade700
                    : Colors.white,
          ),
          6.verticalSpace,
          GenText(
            time,
            size: 12,
            color:
                widget.paymentStatus == PaymentStatus.completed
                    ? appColors.textColor.shade300
                    : Colors.white,
          ),
        ],
      ),
    );
  }
}
