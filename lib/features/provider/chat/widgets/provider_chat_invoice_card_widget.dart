import 'package:resq360/__lib.dart';

class ProviderChatInvoiceCardWidget extends StatelessWidget {
  const ProviderChatInvoiceCardWidget({required this.onTapPay, super.key});

  final void Function() onTapPay;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      padding: pad(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Col(
        children: [
          Container(
            padding: pad(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
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
                          color: appColors.success.shade700,
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
                          color: appColors.success.shade700,
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
                          color: appColors.success.shade700,
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
                          color: appColors.success.shade700,
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
                        color: appColors.success.shade700,
                        weight: FontWeight.w500,
                      ),
                      4.horizontalSpace,
                      AppAssets.ASSETS_ICONS_ARROW_DROPDOWN_SVG.svgColor(
                        color: appColors.success.shade700,
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
                      color: appColors.textColor.shade400,
                    ),
                    GenText(
                      '₦15,000',
                      size: 16,
                      weight: FontWeight.w700,
                      color: appColors.success.shade700,
                    ),
                  ],
                ),
              ],
            ),
          ),
          16.verticalSpace,
          UrbText(
            'Payment Confirmed',
            size: 16,
            height: 26.5,
            weight: FontWeight.w700,
            color: appColors.success.shade700,
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
