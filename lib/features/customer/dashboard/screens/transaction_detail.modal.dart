import 'package:resq360/__lib.dart';

import 'package:resq360/features/customer/dashboard/data/models/wallet_transaction.dart';

class TransactionDetailModal extends StatelessWidget {
  const TransactionDetailModal({
    required this.tx,
    required this.onRetry,
    required this.onSupport,
    super.key,
  });

  final WalletTransaction tx;
  final VoidCallback onRetry;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.75,
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
                tx.title,
                size: 12,
                color: appColors.textColor.shade400,
              ),
              4.verticalSpace,

              UrbText(
                '₦${tx.uiAmount}',
                size: 18,
                weight: FontWeight.w700,
                color: appColors.black,
              ),
              4.verticalSpace,

              GenText(
                tx.status ?? 'UNKNOWN',
                color:
                    tx.status == 'FAILED'
                        ? appColors.error.shade500
                        : appColors.success.shade600,
                weight: FontWeight.w600,
              ),
              20.verticalSpace,
              Divider(color: appColors.textColor.shade100),
              20.verticalSpace,

              _TransactionDetailItem(
                label: 'Invoice No.',
                value: tx.reference ?? '-',
              ),
              _TransactionDetailItem(
                label: 'Description',
                value: tx.description ?? '-',
              ),
              _TransactionDetailItem(
                label: 'Date & Time',
                value: tx.uiDate.isNotEmpty ? tx.uiDate : '-',
              ),
              _TransactionDetailItem(
                label: 'Service ID',
                value: tx.serviceRequestId?.toString() ?? '-',
              ),
              _TransactionDetailItem(
                label: 'Payment Method',
                value: tx.gatewayReference != null ? 'Card' : 'Wallet',
              ),

              if(tx.status == 'FAILED')
              _TransactionDetailItem(
                label: 'Failure Reason',
                value: tx.status == 'FAILED' ? 'Transaction failed' : '-',
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
                  // Expanded(
                  //   child: WideButton(
                  //     label: 'Try Again',
                  //     backgroundColor: appColors.primary.shade500,
                  //     textColor: appColors.whiteColor,
                  //     onPressed: onRetry,
                  //   ),
                  // ),
                ],
              ),
              20.verticalSpace,
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
        children: [
          GenText(
            label,
            size: 12,
            color: appColors.textColor.shade400,
          ),
          20.horizontalSpace,
          Expanded(
            child: GenText(
              value,
              color: appColors.black,
              weight: FontWeight.w500,
              textAlign: TextAlign.end,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
