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

class PaymentReceiptPdfUtil {
  PaymentReceiptPdfUtil._();

  static Future<void> generatePaymentReceiptPdf({
    required String reference,
    required String title,
    required String amount,
    required String status,
    required String dateTime,
    required String paymentMethod,
    String? description,
    String? serviceId,
    String? failureReason,
  }) async {
    final pdf = pw.Document();

    final logo = pw.MemoryImage(
      (await rootBundle.load(
        AppAssets.ASSETS_LOGO_LOGO_PNG,
      )).buffer.asUint8List(),
    );

    final statusColor = status == 'FAILED' ? PdfColors.red : PdfColors.green;

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
                  'Payment Receipt',
                  style: const pw.TextStyle(
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 30),

              pw.Text(
                'Transaction Details',
                style: const pw.TextStyle(
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.Text(
                'Reference No: $reference',
                style: const pw.TextStyle(
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.Text(
                'Transaction: $title',
                style: const pw.TextStyle(
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 10),

              if (description != null && description.isNotEmpty) ...{
                pw.Text(
                  'Description: $description',
                  style: const pw.TextStyle(
                    fontSize: 16,
                  ),
                ),
                pw.SizedBox(height: 10),
              },

              pw.Text(
                'Status: $status',
                style: pw.TextStyle(
                  fontSize: 16,
                  color: statusColor,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.Text(
                'Date & Time: $dateTime',
                style: const pw.TextStyle(
                  fontSize: 16,
                ),
              ),

              if (serviceId != null && serviceId != '-') ...{
                pw.SizedBox(height: 10),
                pw.Text(
                  'Service ID: $serviceId',
                  style: const pw.TextStyle(
                    fontSize: 16,
                  ),
                ),
              },

              pw.SizedBox(height: 20),

              pw.Text(
                'Payment Details',
                style: const pw.TextStyle(
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.Text(
                'Payment Method: $paymentMethod',
                style: const pw.TextStyle(
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.Text(
                'Amount: ₦${AppTextUtil.formatAmount(amount)}',
                style: pw.TextStyle(
                  fontSize: 18,
                  color: statusColor,
                ),
              ),

              if (failureReason != null && failureReason.isNotEmpty) ...{
                pw.SizedBox(height: 20),
                pw.Text(
                  'Failure Reason',
                  style: const pw.TextStyle(
                    fontSize: 18,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  failureReason,
                  style: const pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.red,
                  ),
                ),
              },

              pw.SizedBox(height: 30),
              
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              
              pw.Text(
                'Thank you for using ResQ360!',
                style: const pw.TextStyle(
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.Text(
                'Website: www.resq360.ng',
                style: const pw.TextStyle(
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 5),
              
              pw.Text(
                'For support, please contact our customer service team.',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/payment_receipt_$reference.pdf');
    await file.writeAsBytes(await pdf.save());

    debugPrint('Payment receipt saved at: ${file.path}');

    await OpenFilex.open(file.path);

    final params = ShareParams(
      subject: 'Payment Receipt - $reference',
      files: [XFile(file.path)],
      previewThumbnail: XFile(file.path),
    );

    await SharePlus.instance.share(params);
  }
}
