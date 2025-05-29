import 'dart:io';
import 'dart:typed_data'; // For Uint8List

import 'package:flutter/services.dart' show rootBundle; // For asset loading

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/widgets.dart'; // Already imported via as pw
import 'package:cloudkeja/models/invoice_models.dart';
import 'package:cloudkeja/models/utiils.dart'; // Assuming Utils.formatDate and Utils.formatPrice are here

class PdfApi {
  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name.pdf'); // Ensure .pdf extension
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice) async {
    final pdf = pw.Document();

    // Load Fonts
    pw.Font fontRegular;
    pw.Font fontBold;
    pw.Font fontItalic; // Added Italic
    try {
      fontRegular = pw.Font.ttf(await rootBundle.load("assets/fonts/IBMPlexSans-Regular.ttf"));
      fontBold = pw.Font.ttf(await rootBundle.load("assets/fonts/IBMPlexSans-Bold.ttf"));
      fontItalic = pw.Font.ttf(await rootBundle.load("assets/fonts/IBMPlexSans-Italic.ttf"));
    } catch (e) {
      print("Error loading IBM Plex Sans fonts, falling back to Helvetica: $e");
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
      fontItalic = pw.Font.helveticaOblique();
    }

    // Load Logo Image
    pw.ImageProvider? logoImage;
    try {
      final img = (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List();
      logoImage = pw.MemoryImage(img);
    } catch (e) {
      print("Error loading logo image: $e");
      logoImage = null; // Fallback to no logo
    }

    // Define Theme Colors
    final PdfColor primaryColorPdf = PdfColor.fromHex("#007AFF");
    final PdfColor darkTextColorPdf = PdfColor.fromHex("#100E34");
    final PdfColor normalTextColorPdf = PdfColor.fromHex("#333333");
    final PdfColor lightGreyColorPdf = PdfColors.grey200;
    final PdfColor whiteColorPdf = PdfColors.white;
    final PdfColor tableHeaderColorPdf = primaryColorPdf; // Or a darker shade like PdfColor.fromHex("#0056b3")
    final PdfColor tableHeaderTextPdfColor = whiteColorPdf;
    final PdfColor dividerColorPdf = primaryColorPdf.shade(0.3); // Lighter shade of primary

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: (context) => _buildHeader(
        invoice, 
        logoImage, 
        fontBold, 
        fontRegular, 
        primaryColorPdf, 
        darkTextColorPdf, 
        normalTextColorPdf
      ),
      build: (context) => [
        _buildBillToSection(invoice, fontBold, fontRegular, darkTextColorPdf, normalTextColorPdf),
        pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
        // buildTitle is removed as "INVOICE" is in header. Description can be a note if needed.
        if (invoice.info.description.isNotEmpty)
          _buildDescription(invoice.info.description, fontRegular, normalTextColorPdf),
        pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
        _buildInvoiceTable(
          invoice, 
          fontBold, 
          fontRegular, 
          tableHeaderColorPdf, 
          tableHeaderTextPdfColor, 
          darkTextColorPdf, 
          normalTextColorPdf, 
          lightGreyColorPdf, 
          whiteColorPdf
        ),
        pw.Divider(color: dividerColorPdf, thickness: 0.5),
        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
        _buildTotal(invoice, fontBold, fontRegular, primaryColorPdf, darkTextColorPdf, dividerColorPdf),
      ],
      footer: (context) => _buildFooter(
        invoice, 
        fontRegular, 
        normalTextColorPdf, 
        primaryColorPdf,
        context // Pass context for page numbers
      ),
    ));

    return PdfApi.saveDocument(name: 'Invoice_${invoice.info.number}', pdf: pdf);
  }

  static pw.Widget _buildHeader(
    Invoice invoice, 
    pw.ImageProvider? logoImage, 
    pw.Font fontBold, 
    pw.Font fontRegular, 
    PdfColor primaryColor, 
    PdfColor darkTextColor, 
    PdfColor normalTextColor
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Left Side: Logo and Supplier Details
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  if (logoImage != null) 
                    pw.Container(
                      height: 60, // Adjust height as needed
                      width: 150, // Adjust width as needed
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    ),
                  if (logoImage != null) pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
                  _buildSupplierAddress(invoice.supplier, fontBold, fontRegular, darkTextColor, normalTextColor),
                ],
              ),
            ),
            pw.SizedBox(width: 1 * PdfPageFormat.cm),
            // Right Side: "INVOICE" title and Invoice Info
            pw.Expanded(
              flex: 3,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(font: fontBold, fontSize: 28, color: primaryColor),
                  ),
                  pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
                  _buildInvoiceInfo(invoice.info, fontRegular, darkTextColor),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 1 * PdfPageFormat.cm),
        pw.Divider(color: primaryColor, thickness: 2),
        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
      ],
    );
  }
  
  static pw.Widget _buildSupplierAddress(Supplier supplier, pw.Font fontBold, pw.Font fontRegular, PdfColor darkTextColor, PdfColor normalTextColor) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(supplier.name, style: pw.TextStyle(font: fontBold, fontSize: 12, color: darkTextColor)),
      pw.SizedBox(height: 1 * PdfPageFormat.mm),
      pw.Text(supplier.address, style: pw.TextStyle(font: fontRegular, fontSize: 10, color: normalTextColor), maxLines: 3),
    ],
  );

  static pw.Widget _buildInvoiceInfo(InvoiceInfo info, pw.Font fontRegular, PdfColor textColor) {
    final titles = <String>['Invoice Number:', 'Invoice Date:', 'Due Date:'];
    final data = <String>[
      info.number,
      Utils.formatDate(info.date),
      Utils.formatDate(info.dueDate),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end, // Align text to the right
      children: List.generate(titles.length, (index) {
        return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(titles[index], style: pw.TextStyle(font: fontRegular, fontSize: 10, color: textColor.shade(0.2))), // Slightly lighter title
            pw.SizedBox(width: 0.3 * PdfPageFormat.cm),
            pw.Text(data[index], style: pw.TextStyle(font: fontRegular, fontSize: 10, fontWeight: pw.FontWeight.bold, color: textColor)),
          ],
        );
      }),
    );
  }
  
  static pw.Widget _buildBillToSection(Invoice invoice, pw.Font fontBold, pw.Font fontRegular, PdfColor darkTextColor, PdfColor normalTextColor) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('BILL TO:', style: pw.TextStyle(font: fontBold, fontSize: 11, color: darkTextColor)),
            pw.SizedBox(height: 0.2 * PdfPageFormat.cm),
            pw.Text(invoice.customer.name, style: pw.TextStyle(font: fontRegular, fontSize: 10, color: normalTextColor)),
            if (invoice.customer.address.isNotEmpty)
              pw.Text(invoice.customer.address, style: pw.TextStyle(font: fontRegular, fontSize: 10, color: normalTextColor)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildDescription(String description, pw.Font fontRegular, PdfColor normalTextColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Notes / Description:', style: pw.TextStyle(font: fontRegular, fontSize: 10, fontWeight: pw.FontWeight.bold, color: normalTextColor.shade(0.2))),
        pw.SizedBox(height: 0.2 * PdfPageFormat.cm),
        pw.Text(description, style: pw.TextStyle(font: fontRegular, fontSize: 10, color: normalTextColor)),
      ],
    );
  }

  static pw.Widget _buildInvoiceTable(
    Invoice invoice, 
    pw.Font fontBold, 
    pw.Font fontRegular, 
    PdfColor headerColor,
    PdfColor headerTextColor,
    PdfColor darkTextColor, 
    PdfColor normalTextColor, 
    PdfColor lightRowColor, 
    PdfColor darkRowColor // Usually white for light theme
  ) {
    final headers = ['Description', 'Qty', 'Unit Price', 'Total'];
    
    final data = invoice.items.map((item) {
      return [
        item.description, // Space Name
        item.quantity.toString(),
        Utils.formatPrice(item.unitPrice),
        Utils.formatPrice(item.unitPrice * item.quantity),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null, // No external border
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: headerTextColor),
      headerCellDecoration: pw.BoxDecoration(color: headerColor),
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9, color: normalTextColor),
      rowDecoration: (index, P) => pw.BoxDecoration(
        color: index % 2 == 0 ? darkRowColor : lightRowColor, // Alternating row colors
      ),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      headerCellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      columnWidths: { // Adjust column widths
        0: const pw.FlexColumnWidth(3), // Description wider
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      }
    );
  }

  static pw.Widget _buildTotal(Invoice invoice, pw.Font fontBold, pw.Font fontRegular, PdfColor primaryColor, PdfColor darkTextColor, PdfColor dividerColor) {
    final netTotal = invoice.items.map((item) => item.unitPrice * item.quantity).reduce((a, b) => a + b);
    final double vatRate = 0.0; // Placeholder VAT Rate
    final vatAmount = netTotal * vatRate;
    final total = netTotal + vatAmount;

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 6),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildText(font: fontRegular, title: 'Subtotal', value: Utils.formatPrice(netTotal), color: darkTextColor),
                pw.SizedBox(height: 0.2 * PdfPageFormat.cm),
                _buildText(font: fontRegular, title: 'VAT (${(vatRate * 100).toStringAsFixed(0)}%)', value: Utils.formatPrice(vatAmount), color: darkTextColor),
                pw.Divider(color: dividerColor, thickness: 0.5, height: 1 * PdfPageFormat.cm),
                _buildText(
                  font: fontBold,
                  title: 'Total Amount Due',
                  value: Utils.formatPrice(total),
                  titleStyle: pw.TextStyle(font: fontBold, fontSize: 14, color: primaryColor),
                  valueStyle: pw.TextStyle(font: fontBold, fontSize: 14, color: primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(Invoice invoice, pw.Font fontRegular, PdfColor normalTextColor, PdfColor primaryColor, pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: primaryColor.shade(0.3), thickness: 1),
        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
        pw.Text('Thank you for your business!', style: pw.TextStyle(font: fontRegular, fontSize: 10, color: normalTextColor)),
        pw.SizedBox(height: 0.2 * PdfPageFormat.cm),
        if (invoice.supplier.paymentInfo.isNotEmpty) // Assuming paymentInfo is website/contact
            pw.Text(invoice.supplier.paymentInfo, style: pw.TextStyle(font: fontRegular, fontSize: 9, color: normalTextColor.shade(0.2))),
        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey),
          ),
        )
      ],
    );
  }

  // Updated helper method for text rows
  static pw.Widget _buildText({
    required pw.Font font,
    required String title,
    required String value,
    required PdfColor color,
    pw.TextStyle? titleStyle,
    pw.TextStyle? valueStyle,
    double width = double.infinity,
  }) {
    final style = titleStyle ?? pw.TextStyle(font: font, color: color);
    final valStyle = valueStyle ?? pw.TextStyle(font: font, color: color, fontWeight: pw.FontWeight.bold);

    return pw.Container(
      width: width,
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(title, style: style)),
          pw.Text(value, style: valStyle),
        ],
      ),
    );
  }
}
