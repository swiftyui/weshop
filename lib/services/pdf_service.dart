import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/grocery_item.dart';
import 'settings_service.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAndSharePdf(List<GroceryItem> items) async {
    final pdf = pw.Document();

    // Group items by category
    final groupedItems = <String, List<GroceryItem>>{};
    for (var item in items) {
      if (!groupedItems.containsKey(item.category)) {
        groupedItems[item.category] = [];
      }
      groupedItems[item.category]!.add(item);
    }

    final totalPrice =
        items.fold<double>(0, (sum, item) => sum + (item.estimatedPrice ?? 0));
    final checkedCount = items.where((item) => item.isChecked).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'MilkPlease',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Grocery List',
                style: pw.TextStyle(
                  fontSize: 24,
                  color: PdfColors.blue,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Generated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.SizedBox(height: 20),

              // Summary
              pw.Container(
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue, width: 1),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Summary',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('Total Items: ${items.length}',
                        style: pw.TextStyle(fontSize: 11)),
                    pw.Text('Checked: $checkedCount',
                        style: pw.TextStyle(fontSize: 11)),
                    pw.Text('Remaining: ${items.length - checkedCount}',
                        style: pw.TextStyle(fontSize: 11)),
                    if (totalPrice > 0)
                      pw.Text(
                          'Estimated Total: ${SettingsService.getCurrencySymbol()}${totalPrice.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                              fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Items by category
              ...groupedItems.entries.expand((entry) {
                final category = entry.key;
                final categoryItems = entry.value;
                return [
                  pw.Text(
                    category,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Column(
                    children: categoryItems
                        .map((item) => pw.Padding(
                              padding: pw.EdgeInsets.symmetric(vertical: 4),
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Container(
                                    width: 12,
                                    height: 12,
                                    margin: pw.EdgeInsets.only(right: 8),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                        color: item.isChecked ? PdfColors.blue : PdfColors.grey600,
                                        width: 2,
                                      ),
                                      borderRadius: pw.BorderRadius.circular(2),
                                      color: item.isChecked ? PdfColors.blue : null,
                                    ),
                                    child: item.isChecked
                                        ? pw.Center(
                                            child: pw.Container(
                                              width: 6,
                                              height: 6,
                                              decoration: pw.BoxDecoration(
                                                color: PdfColors.white,
                                                borderRadius: pw.BorderRadius.circular(1),
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  pw.Expanded(
                                    child: pw.Text(
                                      item.name,
                                      style: pw.TextStyle(
                                        fontSize: 11,
                                        decoration: item.isChecked
                                            ? pw.TextDecoration.lineThrough
                                            : null,
                                        color: item.isChecked ? PdfColors.grey600 : PdfColors.black,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    '${item.quantity} ${item.unit}',
                                    style: pw.TextStyle(
                                        fontSize: 10, color: PdfColors.grey700),
                                  ),
                                  if (item.estimatedPrice != null)
                                    pw.Padding(
                                      padding: pw.EdgeInsets.only(left: 12),
                                      child: pw.Text(
                                        '${SettingsService.getCurrencySymbol()}${item.estimatedPrice!.toStringAsFixed(2)}',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  pw.SizedBox(height: 12),
                ];
              }),
            ],
          ),
        ],
      ),
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/MilkPlease_GroceryList.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my grocery list from MilkPlease!',
      );
    } catch (e) {
      rethrow;
    }
  }
}
