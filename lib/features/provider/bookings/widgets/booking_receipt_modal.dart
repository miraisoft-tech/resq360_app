import 'package:resq360/__lib.dart';

class BookingReceiptModal extends ConsumerWidget {
  const BookingReceiptModal({
    required this.service,
    required this.provider,
    required this.status,
    required this.invoice,
    required this.dateTime,
    required this.method,
    required this.onDownload,
    super.key,
  });

  final String service;
  final String provider;
  final String status;
  final String invoice;
  final String dateTime;
  final String method;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      padding: pad(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: appColors.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
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
          10.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 30.w,
              ),
              UrbText(
                'Payment Receipt',
                size: 22,
                height: 32.5,
                weight: FontWeight.w700,
                color: appColors.black,
                textAlign: TextAlign.center,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: appColors.black),
              ),
            ],
          ),
          30.verticalSpace,
          UrbText(
            '₦15,000.00',
            size: 18,
            height: 28.5,
            weight: FontWeight.w700,
            color: appColors.black,
          ),
          4.verticalSpace,
          GenText(
            'Payment Successful',
            size: 12,
            height: 20.5,
            weight: FontWeight.w400,
            color: appColors.success.shade700,
          ),
          const ListDivider(
            verticalSpacing: 20,
          ),
          20.verticalSpace,
          _infoRow('Service', service),
          5.verticalSpace,
          _infoRow('Client', provider),
          5.verticalSpace,
          _infoRow('Invoice No.', invoice),
          5.verticalSpace,
          _infoRow('Date & Time', dateTime, bold: true),
          5.verticalSpace,
          _infoRow('Payment Method', method),
          const Spacer(),

          WideButton(
            label: 'Download Receipt',
            onPressed: onDownload,
          ),
          40.verticalSpace,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GenText(
            label,
            size: 12,
            color: Colors.grey[600],
            weight: FontWeight.w400,
          ),
          GenText(
            value,
            weight: bold ? FontWeight.w600 : FontWeight.w500,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}
