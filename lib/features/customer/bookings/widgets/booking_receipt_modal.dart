import 'package:resq360/__lib.dart';

class BookingReceiptModal extends ConsumerWidget {
  const BookingReceiptModal({
    required this.service,
    required this.provider,
    required this.serviceId,
    required this.status,
    required this.invoice,
    required this.dateTime,
    required this.method,
    required this.onDownload,
    super.key,
  });

  final String service;
  final String provider;
  final String serviceId;
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
      height: MediaQuery.of(context).size.height * 0.7,
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
          10.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 30.w,
              ),
              UrbText(
                'Booking Receipt',
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
          GenText(
            'Booking Info',
            weight: FontWeight.w500,
            color: appColors.black,
          ),
          20.verticalSpace,
          _infoRow('Service', service),
          5.verticalSpace,
          _infoRow('Provider', provider),
          5.verticalSpace,
          _infoRow('Service ID', serviceId),
          5.verticalSpace,
          _infoRow('Status', status),
          const ListDivider(
            verticalSpacing: 20,
          ),
          GenText(
            'Payment Info',
            weight: FontWeight.w500,
            color: appColors.black,
          ),
          20.verticalSpace,
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
