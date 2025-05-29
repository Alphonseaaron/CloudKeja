import 'dart:io';
import 'dart:typed_data'; // For Uint8List

import 'package:flutter/material.dart'; // For DateTimeRange
import 'package:flutter/services.dart' show rootBundle; // For asset loading
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloudkeja/models/payment_model.dart'; // Assuming PaymentModel path
import 'package:cloudkeja/models/user_model.dart';   // Assuming UserModel path
import 'package:intl/intl.dart'; // For date formatting

// Re-using PdfApi from invoice_provider.dart. It could be moved to a shared utils file.
// For now, assuming it's accessible or defined here.
class PdfApi { // Copied from invoice_provider.dart for now
  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}


class UserReportPdfApi {
  static Future<File> generateUserPaymentHistoryPdf(
    List<PaymentModel> payments,
    UserModel currentUser,
    DateTimeRange? filterDateRange,
  ) async {
    final pdf = pw.Document();

    // --- Font Loading ---
    pw.Font fontRegular;
    pw.Font fontBold;
    pw.Font fontItalic;
    try {
      fontRegular = pw.Font.ttf(await rootBundle.load("assets/fonts/IBMPlexSans-Regular.ttf"));
      fontBold = pw.Font.ttf(await rootBundle.load("assets/fonts/IBMPlexSans-Bold.ttf"));
      fontItalic = pw.Font.ttf(await rootBundle.load("assets/fonts/IBMPlexSans-Italic.ttf"));
    } catch (e) {
      print("Error loading IBM Plex Sans fonts for report, falling back to Helvetica: $e");
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
      fontItalic = pw.Font.helveticaOblique();
    }

    // --- Logo Image Loading ---
    pw.ImageProvider? logoImage;
    try {
      final imgBytes = (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List();
      logoImage = pw.MemoryImage(imgBytes);
    } catch (e) {
      print("Error loading logo image for report: $e");
      logoImage = null; 
    }

    // --- Define Theme Colors (as PdfColor) ---
    // These should ideally match the AppTheme.lightTheme for consistency in PDF exports
    final PdfColor primaryColorPdf = PdfColor.fromHex("#007AFF"); // kAppPrimaryColor
    final PdfColor darkTextColorPdf = PdfColor.fromHex("#100E34"); // kAppTextColor (on light surfaces)
    final PdfColor normalTextColorPdf = PdfColor.fromHex("#333333"); // General text
    final PdfColor lightGreyColorPdf = PdfColors.grey200; // For table row alternation
    final PdfColor whiteColorPdf = PdfColors.white;
    final PdfColor tableHeaderColorPdf = primaryColorPdf; 
    final PdfColor tableHeaderTextPdfColor = whiteColorPdf;
    final PdfColor dividerColorPdf = primaryColorPdf.shade(0.3);

    // --- PDF Page Build ---
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32), // Standard A4 margins
        header: (context) => _buildReportHeader(
          currentUser, 
          filterDateRange, 
          logoImage, 
          fontBold, 
          fontRegular, 
          primaryColorPdf, 
          darkTextColorPdf
        ),
        build: (context) => [
          _buildPaymentHistoryTable(
            payments, 
            fontBold, 
            fontRegular, 
            tableHeaderColorPdf, 
            tableHeaderTextPdfColor, 
            darkTextColorPdf, 
            normalTextColorPdf, 
            lightGreyColorPdf, 
            whiteColorPdf
          ),
          if (payments.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 40),
              child: pw.Center(
                child: pw.Text(
                  'No payment records found for the selected period.',
                  style: pw.TextStyle(font: fontItalic, fontSize: 12, color: normalTextColorPdf.shade(0.3)),
                ),
              ),
            ),
        ],
        footer: (context) => _buildReportFooter(
          fontRegular, 
          normalTextColorPdf.shade(0.2), // Lighter footer text
          context
        ),
      ),
    );

    final reportName = 'PaymentHistory_${currentUser.name?.replaceAll(" ", "_") ?? "User"}_${DateFormat('yyyyMMdd').format(DateTime.now())}';
    return PdfApi.saveDocument(name: reportName, pdf: pdf);
  }

  // --- Header Builder ---
  static pw.Widget _buildReportHeader(
    UserModel currentUser,
    DateTimeRange? filterDateRange,
    pw.ImageProvider? logoImage,
    pw.Font fontBold,
    pw.Font fontRegular,
    PdfColor primaryColor,
    PdfColor darkTextColor,
  ) {
    String reportPeriod = "All Time";
    if (filterDateRange != null) {
      reportPeriod = 
          "${DateFormat.yMMMd().format(filterDateRange.start)} - ${DateFormat.yMMMd().format(filterDateRange.end)}";
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logoImage != null)
                  pw.SizedBox(
                    height: 40, // Adjust logo size
                    width: 120,
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                if (logoImage != null) pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
                pw.Text(
                  'Payment History Report',
                  style: pw.TextStyle(font: fontBold, fontSize: 18, color: primaryColor),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(currentUser.name ?? 'N/A User', style: pw.TextStyle(font: fontBold, fontSize: 12, color: darkTextColor)),
                pw.Text(currentUser.email ?? '', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: darkTextColor.shade(0.3))),
                pw.SizedBox(height: 0.3 * PdfPageFormat.cm),
                pw.Text('Report Period: $reportPeriod', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: darkTextColor.shade(0.2))),
                pw.Text('Generated: ${DateFormat.yMMMd().add_jm().format(DateTime.now())}', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: darkTextColor.shade(0.2))),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
        pw.Divider(color: primaryColor.shade(0.5), thickness: 1.5),
        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
      ],
    );
  }

  // --- Table Builder ---
  static pw.Widget _buildPaymentHistoryTable(
    List<PaymentModel> payments,
    pw.Font fontBold,
    pw.Font fontRegular,
    PdfColor headerColor,
    PdfColor headerTextColor,
    PdfColor darkTextColor, // For important text in rows
    PdfColor normalTextColor, // For regular text in rows
    PdfColor lightRowColor, // For alternating rows
    PdfColor darkRowColor,  // Usually white or very light grey
  ) {
    final headers = ['Date', 'Description', 'Method', 'Trans. ID', 'Status', 'Amount'];
    
    final data = payments.map((payment) {
      return [
        DateFormat.yMd().format(payment.date.toDate()),
        payment.description,
        payment.paymentMethod ?? 'N/A',
        payment.transactionId ?? 'N/A',
        payment.status,
        '${payment.currency} ${payment.amount.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5), // Subtle border
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 9, color: headerTextColor),
      headerCellDecoration: pw.BoxDecoration(color: headerColor),
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 8, color: normalTextColor),
      rowDecoration: (index, P) => pw.BoxDecoration(
        color: index % 2 == 0 ? darkRowColor : lightRowColor,
      ),
      cellHeight: 25, // Adjust height
      cellAlignments: {
        0: pw.Alignment.centerLeft,  // Date
        1: pw.Alignment.centerLeft,  // Description
        2: pw.Alignment.centerLeft,  // Method
        3: pw.Alignment.centerLeft,  // Trans. ID
        4: pw.Alignment.center,      // Status
        5: pw.Alignment.centerRight, // Amount
      },
      headerCellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      columnWidths: { // Adjust column widths
        0: const pw.FixedColumnWidth(60),    // Date
        1: const pw.FlexColumnWidth(2.5),   // Description (wider)
        2: const pw.FixedColumnWidth(50),    // Method
        3: const pw.FixedColumnWidth(70),    // Trans. ID
        4: const pw.FixedColumnWidth(50),    // Status
        5: const pw.FixedColumnWidth(70),    // Amount
      }
    );
  }

  // --- Footer Builder ---
  static pw.Widget _buildReportFooter(
    pw.Font fontRegular,
    PdfColor footerTextColor,
    pw.Context context,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: footerTextColor.shade(0.5), thickness: 0.5),
        pw.SizedBox(height: 0.3 * PdfPageFormat.cm),
        pw.Text('CloudKeja Platform - Your Trusted Partner in Property Management.', style: pw.TextStyle(font: fontRegular, fontSize: 8, color: footerTextColor)),
        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: fontRegular, fontSize: 8, color: footerTextColor),
          ),
        )
      ],
    );
  }
}
