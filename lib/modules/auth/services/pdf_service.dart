import 'dart:typed_data';
import 'dart:html' as html;
import 'package:inventario_merca_inc/modules/auth/controllers/report_config.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfService {
  static Future<Uint8List> generatePDF({
    required ReportConfig config,
    required List<Map<String, dynamic>> data,
    required Uint8List backgroundImage,
  }) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(backgroundImage);
    final fechaGeneracion = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    const int maxRowsPerPage = 13; // 14 en total contando encabezado
    int totalPages = (data.length / maxRowsPerPage).ceil();

    for (int i = 0; i < totalPages; i++) {
      int start = i * maxRowsPerPage;
      int end = start + maxRowsPerPage;
      if (end > data.length) end = data.length;
      
      List<Map<String, dynamic>> pageData = data.sublist(start, end);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Opacity(
                  opacity: 1,
                  child: pw.Image(image, fit: pw.BoxFit.cover),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildHeader(config.title, fechaGeneracion, i + 1, totalPages),
                      pw.SizedBox(height: 8),
                      _buildTableSection(config, pageData),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _buildHeader(String title, String fecha, int page, int totalPages) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 0), // Ajusta este valor según la distancia deseada
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 5), // Espacio entre título y fecha
        pw.Text(
          'Generado: $fecha  |  Página $page de $totalPages',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableSection(ReportConfig config, List<Map<String, dynamic>> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.3),
      columnWidths: _calculateColumnWidths(),
      children: [
        _buildTableHeader(config.headers),
        ..._buildTableRows(config.fields, data),
      ],
    );
  }

  static Map<int, pw.TableColumnWidth> _calculateColumnWidths() {
    return {
      0: pw.FixedColumnWidth(65),
      1: pw.FlexColumnWidth(3.2),
      2: pw.FlexColumnWidth(2.2),
      3: pw.FlexColumnWidth(2.8),
      4: pw.FlexColumnWidth(5.5),
      5: pw.FlexColumnWidth(3.2),
      6: pw.FlexColumnWidth(3.5),
      7: pw.FixedColumnWidth(85),
      8: pw.FlexColumnWidth(4.2),
      9: pw.FlexColumnWidth(3.8),
      10: pw.FlexColumnWidth(4.8),
      11: pw.FlexColumnWidth(4.8),
    };
  }

  static pw.TableRow _buildTableHeader(List<String> headers) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.blueGrey100),
      children: headers.map((header) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 3),
        child: pw.Text(
          header,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
          textAlign: pw.TextAlign.center,
          maxLines: 2,
        ),
      )).toList(),
    );
  }

  static List<pw.TableRow> _buildTableRows(List<String> fields, List<Map<String, dynamic>> data) {
    return data.map((item) => pw.TableRow(
      children: fields.map((field) => _buildTableCell(
        item[field]?.toString().replaceAll('\n', ' ') ?? 'N/A',
      )).toList(),
    )).toList();
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }
}