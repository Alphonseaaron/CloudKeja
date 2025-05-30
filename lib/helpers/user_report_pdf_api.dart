import 'dart:io';
import 'dart:typed_data'; // For Uint8List

import 'package:flutter/material.dart'; // For DateTimeRange
import 'package:flutter/services.dart' show rootBundle; // For asset loading
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloudkeja/models/payment_model.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/models/sp_job_model.dart'; // Import SPJobModel
import 'package:intl/intl.dart'; // For date formatting

class PdfApi {
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


class UserReportPdfApi { // Renaming to ReportPdfApi or similar could be better if it handles multiple report types

  // --- Common Font Loading ---
  static Future<Map<String, pw.Font>> _loadFonts() async {
    try {
      return {
        'regular': pw.Font.ttf(await rootBundle.load("assets/fonts/IBMPlexSans-Regular.ttf")),
        'bold': pw.Font.ttf(await rootBundle.load("assets/fonts/IBMPlexSans-Bold.ttf")),
        'italic': pw.Font.ttf(await rootBundle.load("assets/fonts/IBMPlexSans-Italic.ttf")),
      };
    } catch (e) {
      print("Error loading IBM Plex Sans fonts, falling back to Helvetica: $e");
      return {
        'regular': pw.Font.helvetica(),
        'bold': pw.Font.helveticaBold(),
        'italic': pw.Font.helveticaOblique(),
      };
    }
  }

  // --- Common Logo Image Loading ---
  static Future<pw.ImageProvider?> _loadLogo() async {
    try {
      final imgBytes = (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List();
      return pw.MemoryImage(imgBytes);
    } catch (e) {
      print("Error loading logo image for report: $e");
      return null;
    }
  }

  // --- Common Color Definitions ---
  static final PdfColor _primaryColorPdf = PdfColor.fromHex("#007AFF");
  static final PdfColor _darkTextColorPdf = PdfColor.fromHex("#100E34");
  static final PdfColor _normalTextColorPdf = PdfColor.fromHex("#333333");
  static final PdfColor _lightGreyColorPdf = PdfColors.grey200;
  static final PdfColor _whiteColorPdf = PdfColors.white;
  static final PdfColor _tableHeaderColorPdf = _primaryColorPdf;
  static final PdfColor _tableHeaderTextPdfColor = _whiteColorPdf;
  // static final PdfColor _dividerColorPdf = _primaryColorPdf.shade(0.3); // Not used directly here but good for consistency


  static Future<File> generateUserPaymentHistoryPdf(
    List<PaymentModel> payments,
    UserModel currentUser,
    DateTimeRange? filterDateRange,
  ) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    final logoImage = await _loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildReportHeader(
          reportTitle: 'Payment History Report',
          user: currentUser,
          filterDateRange: filterDateRange,
          logoImage: logoImage,
          fontBold: fonts['bold']!,
          fontRegular: fonts['regular']!,
          primaryColor: _primaryColorPdf,
          darkTextColor: _darkTextColorPdf
        ),
        build: (context) => [
          _buildPaymentHistoryTable(
            payments,
            fonts['bold']!,
            fonts['regular']!,
            _tableHeaderColorPdf,
            _tableHeaderTextPdfColor,
            _darkTextColorPdf,
            _normalTextColorPdf,
            _lightGreyColorPdf,
            _whiteColorPdf
          ),
          if (payments.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 40),
              child: pw.Center(
                child: pw.Text(
                  'No payment records found for the selected period.',
                  style: pw.TextStyle(font: fonts['italic']!, fontSize: 12, color: _normalTextColorPdf.shade(0.3)),
                ),
              ),
            ),
        ],
        footer: (context) => _buildReportFooter(
          fonts['regular']!,
          _normalTextColorPdf.shade(0.2),
          context
        ),
      ),
    );

    final reportName = 'PaymentHistory_${currentUser.name?.replaceAll(" ", "_") ?? "User"}_${DateFormat('yyyyMMdd').format(DateTime.now())}';
    return PdfApi.saveDocument(name: reportName, pdf: pdf);
  }

  // Generic Report Header
  static pw.Widget _buildReportHeader({
    required String reportTitle,
    required UserModel user,
    DateTimeRange? filterDateRange,
    pw.ImageProvider? logoImage,
    required pw.Font fontBold,
    required pw.Font fontRegular,
    required PdfColor primaryColor,
    required PdfColor darkTextColor,
  }) {
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
                    height: 40,
                    width: 120,
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                if (logoImage != null) pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
                pw.Text(
                  reportTitle, // Use passed report title
                  style: pw.TextStyle(font: fontBold, fontSize: 18, color: primaryColor),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(user.name ?? 'N/A User', style: pw.TextStyle(font: fontBold, fontSize: 12, color: darkTextColor)),
                pw.Text(user.email ?? '', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: darkTextColor.shade(0.3))),
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

  // Payment History Table (existing)
  static pw.Widget _buildPaymentHistoryTable(
    List<PaymentModel> payments,
    pw.Font fontBold,
    pw.Font fontRegular,
    PdfColor headerColor,
    PdfColor headerTextColor,
    PdfColor darkTextColor,
    PdfColor normalTextColor,
    PdfColor lightRowColor,
    PdfColor darkRowColor,
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

    return pw.TableHelper.fromTextArray( /* ... existing implementation ... */
      headers: headers, data: data, border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 9, color: headerTextColor),
      headerCellDecoration: pw.BoxDecoration(color: headerColor),
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 8, color: normalTextColor),
      rowDecoration: (index, P) => pw.BoxDecoration(color: index % 2 == 0 ? darkRowColor : lightRowColor),
      cellHeight: 25,
      cellAlignments: { 0: pw.Alignment.centerLeft, 1: pw.Alignment.centerLeft, 2: pw.Alignment.centerLeft, 3: pw.Alignment.centerLeft, 4: pw.Alignment.center, 5: pw.Alignment.centerRight, },
      headerCellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      columnWidths: { 0: const pw.FixedColumnWidth(60), 1: const pw.FlexColumnWidth(2.5), 2: const pw.FixedColumnWidth(50), 3: const pw.FixedColumnWidth(70), 4: const pw.FixedColumnWidth(50), 5: const pw.FixedColumnWidth(70), }
    );
  }

  // --- NEW: SP Job History PDF Generation ---
  static Future<File> generateSPJobHistoryPdf(
    List<SPJobModel> jobs,
    UserModel currentSP,
    DateTimeRange? filterDateRange,
  ) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts(); // Reuse font loading
    final logoImage = await _loadLogo(); // Reuse logo loading

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildReportHeader( // Reuse generic header
          reportTitle: 'Job/Task History Report',
          user: currentSP,
          filterDateRange: filterDateRange,
          logoImage: logoImage,
          fontBold: fonts['bold']!,
          fontRegular: fonts['regular']!,
          primaryColor: _primaryColorPdf,
          darkTextColor: _darkTextColorPdf
        ),
        build: (context) => [
          _buildSPJobHistoryTable(
            jobs,
            fonts['bold']!,
            fonts['regular']!,
            _tableHeaderColorPdf,
            _tableHeaderTextPdfColor,
            _darkTextColorPdf,
            _normalTextColorPdf,
            _lightGreyColorPdf,
            _whiteColorPdf
          ),
          if (jobs.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 40),
              child: pw.Center(
                child: pw.Text(
                  'No job records found for the selected period.',
                  style: pw.TextStyle(font: fonts['italic']!, fontSize: 12, color: _normalTextColorPdf.shade(0.3)),
                ),
              ),
            ),
        ],
        footer: (context) => _buildReportFooter(
          fonts['regular']!,
          _normalTextColorPdf.shade(0.2),
          context
        ),
      ),
    );

    final reportName = 'SP_JobHistory_${currentSP.name?.replaceAll(" ", "_") ?? "ServiceProvider"}_${DateFormat('yyyyMMdd').format(DateTime.now())}';
    return PdfApi.saveDocument(name: reportName, pdf: pdf);
  }

  // --- NEW: Table Builder for SP Job History ---
  static pw.Widget _buildSPJobHistoryTable(
    List<SPJobModel> jobs,
    pw.Font fontBold,
    pw.Font fontRegular,
    PdfColor headerColor,
    PdfColor headerTextColor,
    PdfColor darkTextColor,
    PdfColor normalTextColor,
    PdfColor lightRowColor,
    PdfColor darkRowColor,
  ) {
    final headers = ['Date', 'Client', 'Service', 'Address', 'Status', 'Amount'];

    final data = jobs.map((job) {
      return [
        DateFormat.yMd().format(job.dateCompleted), // Assuming dateCompleted is the relevant date
        job.clientName,
        job.serviceDescription,
        job.propertyAddress ?? 'N/A',
        job.status,
        'KES ${job.amountEarned.toStringAsFixed(2)}', // Assuming KES currency
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 9, color: headerTextColor),
      headerCellDecoration: pw.BoxDecoration(color: headerColor),
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 8, color: normalTextColor),
      rowDecoration: (index, P) => pw.BoxDecoration(
        color: index % 2 == 0 ? darkRowColor : lightRowColor,
      ),
      cellHeight: 28, // Adjusted height
      cellAlignments: {
        0: pw.Alignment.centerLeft,  // Date
        1: pw.Alignment.centerLeft,  // Client
        2: pw.Alignment.centerLeft,  // Service
        3: pw.Alignment.centerLeft,  // Address
        4: pw.Alignment.center,      // Status
        5: pw.Alignment.centerRight, // Amount
      },
      headerCellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      columnWidths: {
        0: const pw.FixedColumnWidth(60),    // Date
        1: const pw.FlexColumnWidth(1.5),   // Client
        2: const pw.FlexColumnWidth(2.5),   // Service Description
        3: const pw.FlexColumnWidth(1.5),   // Address
        4: const pw.FixedColumnWidth(55),    // Status (slightly wider for "InProgress")
        5: const pw.FixedColumnWidth(70),    // Amount
      }
    );
  }


  // --- Footer Builder (existing, reusable) ---
  static pw.Widget _buildReportFooter(
    pw.Font fontRegular,
    PdfColor footerTextColor,
    pw.Context context,
  ) {
    return pw.Column( /* ... existing implementation ... */
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
