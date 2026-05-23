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
    
    final statusColor =
        status.toUpperCase() == 'FAILED' || status.toUpperCase() == 'CANCELLED'
            ? PdfColors.red
            : PdfColors.green;

    pdf.addPage(
      pw.Page(
        pageTheme: const pw.PageTheme(margin: pw.EdgeInsets.all(32)),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              width: 300,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(12),
                      color: PdfColors.grey100,
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Image(logo, height: 50),
                        pw.Text(
                          'Booking Receipt',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 24),

                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: statusColor, width: 1.5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Status',
                              style: const pw.TextStyle(fontSize: 14),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: pw.BoxDecoration(
                                color: statusColor,
                                borderRadius: pw.BorderRadius.circular(20),
                              ),
                              child: pw.Text(
                                status,
                                style: const pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // if (hasAmount) ...[
                          pw.SizedBox(height: 12),
                          pw.Text(
                            'NGN ${AppTextUtil.formatAmount(amount)}',
                            style: pw.TextStyle(
                              fontSize: 28,
                              fontWeight: pw.FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        // ],
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 24),

                  _infoCard(
                    title: 'Booking Details',
                    rows: [
                      _infoRow('Booking ID', bookingId),
                      _infoRow('Service', service),
                      _infoRow('Date & Time', dateTime),
                      if (providerName != null && providerName.isNotEmpty)
                        _infoRow('Provider', providerName),
                      if (clientName != null && clientName.isNotEmpty)
                        _infoRow('Client', clientName),
                    ],
                  ),

                  pw.SizedBox(height: 16),

                  // Payment Details
                  _infoCard(
                    title: 'Payment Details',
                    rows: [
                      _infoRow('Payment Method', paymentMethod),
                      _infoRow(
                        'Amount',
                        'NGN ${AppTextUtil.formatAmount(amount)}'
                          
                      ),
                    ],
                  ),

                  pw.Spacer(),

                  pw.Divider(),

                  pw.SizedBox(height: 8),

                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text('Thank you for using ResQ360!'),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'www.resq360.ng',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'For support, please contact our customer service team.',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

pw.Widget _infoCard({
  required String title,
  required List<pw.Widget> rows,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      borderRadius: pw.BorderRadius.circular(12),
      color: PdfColors.grey100,
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        ...rows,
      ],
    ),
  );
}

pw.Widget _infoRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 6),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
