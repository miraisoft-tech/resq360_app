import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/gen/assets.dart';
import 'package:share_plus/share_plus.dart';

class BookingReceiptPdfUtil {
  BookingReceiptPdfUtil._();

  static Future<void> generateBookingReceiptPdf({
    required String bookingId,
    required String service,
    required String status,
    required String dateTime,
    required String paymentMethod,
    required String amount,
    String? providerName,
    String? clientName,
  }) async {
    final pdf = pw.Document();

    final logo = pw.MemoryImage(
      (await rootBundle.load(
        AppAssets.ASSETS_LOGO_LOGO_PNG,
      )).buffer.asUint8List(),
    );

    final hasAmount = amount.isNotEmpty && amount != 'To be billed';

    // final interRegular = pw.Font.ttf(
    //   await rootBundle.load('fonts/Inter/Inter-Regular.otf'),
    // );

    // final interBold = pw.Font.ttf(
    //   await rootBundle.load('fonts/Inter/Inter-Bold.otf'),
    // );

    pdf.addPage(
      pw.Page(
        pageTheme: const pw.PageTheme(margin: pw.EdgeInsets.all(30)),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Image(logo, height: 80)),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Service Receipt',
                  style: const pw.TextStyle(
                    // font: interBold,
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'Booking Details',
                style: const pw.TextStyle(
                  // font: interBold,
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Booking ID: $bookingId',
                style: const pw.TextStyle(
                  // font: interRegular,
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Service: $service',
                style: const pw.TextStyle(
                  // font: interRegular,
                  fontSize: 16,
                ),
              ),
              if (providerName != null) ...{
                pw.SizedBox(height: 10),
                pw.Text(
                  'Provider: $providerName',
                  style: const pw.TextStyle(
                    // font: interRegular,
                    fontSize: 16,
                  ),
                ),
              },
              if (clientName != null) ...{
                pw.SizedBox(height: 10),
                pw.Text(
                  'client: $clientName',
                  style: const pw.TextStyle(
                    // font: interRegular,
                    fontSize: 16,
                  ),
                ),
              },

              pw.SizedBox(height: 10),
              pw.Text(
                'Status: $status',
                style: const pw.TextStyle(
                  // font: interRegular,
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Date & Time: $dateTime',
                style: const pw.TextStyle(
                  // font: interRegular,
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Payment Details',
                style: const pw.TextStyle(
                  // font: interBold,
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Payment Method: $paymentMethod',
                style: const pw.TextStyle(
                  // font: interRegular,
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                hasAmount ? 'Amount Paid: ₦${AppTextUtil.formatAmount(amount)} app' : 'Amount: To be billed',
                style: const pw.TextStyle(
                  // font: interBold,
                  fontSize: 18,
                  color: PdfColors.green,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Thank you for using ResQ360!',
                style: const pw.TextStyle(
                  // font: interRegular,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Website: www.resq360.ng',
                style: const pw.TextStyle(
                  // font: interRegular,
                  fontSize: 14,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/booking_receipt_$bookingId.pdf');

    await OpenFilex.open(file.path);
    await file.writeAsBytes(await pdf.save());

    debugPrint(file.path);

    final params = ShareParams(
      subject: 'Service Receipt',
      files: [XFile(file.path)],
      previewThumbnail: XFile(file.path),
    );

    await SharePlus.instance.share(params);
  }
}
