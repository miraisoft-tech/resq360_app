import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';

class ChatInvoiceCardWidget extends StatefulWidget {
  const ChatInvoiceCardWidget({
    required this.onTapPay,
    required this.metadata,
    required this.messageCreatedAt,
    required this.message,
    required this.chat,
    required this.status,
    super.key,
  });

  final void Function() onTapPay;
  final Metadata metadata;
  final MessageResponse message;
  final ChatResponse chat;
  final String messageCreatedAt;
  final String status;

  @override
  State<ChatInvoiceCardWidget> createState() => _ChatInvoiceCardWidgetState();
}

class _ChatInvoiceCardWidgetState extends State<ChatInvoiceCardWidget> {
  bool viewMore = false;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    log(widget.status);
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
                    widget.metadata.invoiceId ?? '—',
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
                    widget.chat.createdAt?.formatDate ?? '—',
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
                    widget.chat.serviceName ?? '—',
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
                    widget.chat.user?.fullName ?? '',
                    size: 12,
                    weight: FontWeight.w400,
                    color: appColors.textColor.shade300,
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
                    color: context.appColors.primary,
                    weight: FontWeight.w500,
                  ),
                  4.horizontalSpace,
                  Transform.flip(
                    flipY: viewMore,
                    child: AppAssets.ASSETS_ICONS_ARROW_DROPDOWN_SVG.svg,
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
                const GenText(
                  'Service Type',
                  weight: FontWeight.w500,
                ),
                2.verticalSpace,
                GenText(
                  widget.chat.serviceName ?? '-',
                  size: 12,
                  color: context.appColors.textColor.shade300,
                ),
                10.verticalSpace,
                const GenText(
                  'Description',
                  weight: FontWeight.w500,
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
                    color: context.appColors.black,
                  ),
                  2.verticalSpace,
                  GenText(
                    AppTextUtil.formatDateToString(widget.metadata.date!,),
                    size: 12,
                    color: appColors.success.shade700
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
                color: appColors.textColor.shade400,
              ),
              GenText(
                'NGN${AppTextUtil.formatAmount(widget.metadata.amount?.toString() ?? '0')}',
                size: 15,
                weight: FontWeight.w700,
                color: appColors.black,
              ),
            ],
          ),
          16.verticalSpace,
          WideButton(
            label:
                widget.status == PaymentStatus.completed.value
                    ? 'Paid'
                    : 'Pay Now',
            onPressed:
                widget.status != PaymentStatus.completed.value
                    ? widget.onTapPay
                    : null,
          ),
          6.verticalSpace,
          GenText(
            widget.messageCreatedAt,
            size: 12,
            color: appColors.textColor.shade300,
          ),
        ],
      ),
    );
  }
}
