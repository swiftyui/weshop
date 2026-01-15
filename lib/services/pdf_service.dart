import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/grocery_item.dart';
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
                          'Estimated Total: \$${totalPrice.toStringAsFixed(2)}',
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
                                  pw.Expanded(
                                    child: pw.Text(
                                      '${item.isChecked ? '✓ ' : '○ '}${item.name}',
                                      style: pw.TextStyle(
                                        fontSize: 11,
                                        decoration: item.isChecked
                                            ? pw.TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    '${item.quantity} ${item.unit}',
                                    style: pw.TextStyle(
                                        fontSize: 10, color: PdfColors.grey),
                                  ),
                                  if (item.estimatedPrice != null)
                                    pw.Text(
                                      '\$${item.estimatedPrice!.toStringAsFixed(2)}',
                                      style: pw.TextStyle(fontSize: 10),
                                    ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  pw.SizedBox(height: 12),
                ];
              }).toList(),
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
