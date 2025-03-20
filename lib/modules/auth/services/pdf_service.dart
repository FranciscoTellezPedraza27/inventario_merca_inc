import 'dart:typed_data';
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Opacity(
                opacity: 0.15,
                child: pw.Image(image, fit: pw.BoxFit.cover),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildHeader(config.title, fechaGeneracion),
                    pw.SizedBox(height: 8),
                    _buildTableSection(config, data),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  static pw.Widget _buildHeader(String title, String fecha) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 200,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
        ),
        pw.Text(
          'Generado: $fecha',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          )
        )
      ]
    );
  }

  static pw.Widget _buildTableSection(ReportConfig config, List<Map<String, dynamic>> data) {
    return pw.Expanded(
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.3),
        columnWidths: _calculateColumnWidths(),
        children: [
          _buildTableHeader(config.headers),
          ..._buildTableRows(config.fields, data),
        ],
      ),
    );
  }

  static Map<int, pw.TableColumnWidth> _calculateColumnWidths() {
    return {
      0: pw.FixedColumnWidth(65),   // Cantidad
      1: pw.FlexColumnWidth(3.2),   // Artículo
      2: pw.FlexColumnWidth(2.2),   // Marca
      3: pw.FlexColumnWidth(2.8),   // Modelo
      4: pw.FlexColumnWidth(5.5),   // Especificaciones
      5: pw.FlexColumnWidth(3.2),   // N° Producto
      6: pw.FlexColumnWidth(3.5),   // N° Serie
      7: pw.FixedColumnWidth(85),   // Antigüedad
      8: pw.FlexColumnWidth(4.2),   // Valor Aproximado
      9: pw.FlexColumnWidth(3.8),   // Responsable
      10: pw.FlexColumnWidth(4.8),  // Responsabilidad
      11: pw.FlexColumnWidth(4.8),  // Ubicación
    };
  }

  static pw.TableRow _buildTableHeader(List<String> headers) {
    return pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.middle,
      decoration: pw.BoxDecoration(color: PdfColors.blueGrey100),
      children: headers.map((header) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 3),
        child: pw.Text(
          header, // Texto original sin mayúsculas
          style: pw.TextStyle(
            fontSize: 8.5, // Tamaño reducido 0.5pt
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
            letterSpacing: -0.1, // Compactar letras
          ),
          textAlign: pw.TextAlign.center,
          softWrap: true,
          maxLines: 2,
        ),
      )).toList(),
    );
  }

  static List<pw.TableRow> _buildTableRows(List<String> fields, List<Map<String, dynamic>> data) {
    return data.map((item) => pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: fields.map((field) => _buildTableCell(
        item[field]?.toString().replaceAll('\n', ' ') ?? 'N/A',
      )).toList(),
    )).toList();
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      constraints: const pw.BoxConstraints(minHeight: 20),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(
          color: PdfColors.black,
          fontSize: 9,
        ),
      ),
    );
  }
}