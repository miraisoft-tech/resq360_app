import 'package:resq360/__lib.dart';

class TransactionDetailModal extends ConsumerWidget {
  const TransactionDetailModal({
    required this.onRetry,
    required this.onSupport,
    super.key,
  });

  final VoidCallback onRetry;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.65,
      padding: pad(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: appColors.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Col(
        children: [
          Center(
            child: Container(
              height: 3.h,
              width: 50.w,
              decoration: BoxDecoration(
                color: appColors.neutral.shade100,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: appColors.textColor.shade400,
                      ),
                    ),
                  ),
                ],
              ),
              UrbText(
                'Transaction Details',
                size: 22,
                weight: FontWeight.w700,
                color: appColors.black,
              ),
              20.verticalSpace,
              GenText(
                'Transfer to QuickTow Emergency',
                size: 12,
                color: appColors.textColor.shade400,
              ),
              4.verticalSpace,
              UrbText(
                '₦15,000.00',
                size: 18,
                weight: FontWeight.w700,
                color: appColors.black,
              ),
              4.verticalSpace,
              GenText(
                'Failed',
                color: appColors.error.shade500,
                weight: FontWeight.w600,
              ),
              20.verticalSpace,
              Divider(color: appColors.textColor.shade100),
              20.verticalSpace,
              const _TransactionDetailItem(
                label: 'Invoice No.',
                value: '#INV-238777',
              ),
              const _TransactionDetailItem(
                label: 'Description',
                value: 'Payment for towing van',
              ),
              const _TransactionDetailItem(
                label: 'Date & Time',
                value: 'Aug 27, 2025 - 5:16pm',
              ),
              const _TransactionDetailItem(
                label: 'Service ID',
                value: 'TXN-20250815-PLUMB123',
              ),
              const _TransactionDetailItem(
                label: 'Payment Method',
                value: 'Card',
              ),
              const _TransactionDetailItem(
                label: 'Failure Reason',
                value: 'Network Error',
              ),
              24.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: WideButton(
                      label: 'Contact Support',
                      backgroundColor: appColors.error.shade50,
                      textColor: appColors.primary.shade500,
                      onPressed: onSupport,
                    ),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: WideButton(
                      label: 'Try Again',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: onRetry,
                    ),
                  ),
                ],
              ),
              WideButton(
                label: 'Download Receipt',
                backgroundColor: appColors.primary.shade500,
                textColor: appColors.whiteColor,
                onPressed: onRetry,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionDetailItem extends StatelessWidget {
  const _TransactionDetailItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GenText(
            label,
            size: 12,
            color: appColors.textColor.shade400,
          ),
          GenText(
            value,
            color: appColors.black,
            weight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
