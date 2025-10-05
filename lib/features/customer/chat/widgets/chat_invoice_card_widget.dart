import 'package:resq360/__lib.dart';

class ChatInvoiceCardWidget extends StatelessWidget {
  const ChatInvoiceCardWidget({required this.onTapPay, super.key});

  final void Function() onTapPay;
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
                    '#INV-238777',
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
                    '8/27/2025',
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
                    'QuickTow Emergency',
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
                    'Jane Doe',
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
                '₦15,000',
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
            '2:36 pm',
            size: 12,
            color: appColors.textColor.shade300,
          ),
        ],
      ),
    );
  }
}
