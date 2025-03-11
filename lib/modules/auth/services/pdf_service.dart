import 'dart:typed_data';
import 'package:inventario_merca_inc/modules/auth/controllers/report_config.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<Uint8List> generatePDF({
    required ReportConfig config,
    required List<Map<String, dynamic>> data,
    required Uint8List backgroundImage,
  }) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(backgroundImage);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Opacity(
                opacity: 0.5,
                child: pw.Image(image, fit: pw.BoxFit.cover),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  children: [
                    pw.Text(
                      config.title,
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 20),
                    _buildDynamicTable(config, data),
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

  static pw.Widget _buildDynamicTable(ReportConfig config, List<Map<String, dynamic>> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1),
      columnWidths: _calculateColumnWidths(config.headers),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue),
          children: config.headers.map((header) => _buildHeaderCell(header)).toList(),
        ),
        ...data.map((item) => pw.TableRow(
          children: config.fields.map((field) => _buildDataCell(item[field]?.toString() ?? 'N/A')).toList(),
        )).toList(),
      ],
    );
  }

  static Map<int, pw.TableColumnWidth> _calculateColumnWidths(List<String> headers) {
    final Map<int, pw.TableColumnWidth> columnWidths = {};
    final double totalWidth = 600;

    // Asigna anchos específicos a las columnas según el contenido esperado
    columnWidths[0] = pw.FixedColumnWidth(55); // Cantidad
    columnWidths[1] = pw.FixedColumnWidth(60); // Artículo
    columnWidths[2] = pw.FixedColumnWidth(60); // Marca
    columnWidths[3] = pw.FixedColumnWidth(70); // Modelo
    columnWidths[4] = pw.FixedColumnWidth(90); // Especificaciones (más ancho)
    columnWidths[5] = pw.FixedColumnWidth(70); // N° Producto
    columnWidths[6] = pw.FixedColumnWidth(60); // N° Serie
    columnWidths[7] = pw.FixedColumnWidth(70); // Antigüedad

    return columnWidths;
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          fontSize: 12,
        ),
        textAlign: pw.TextAlign.center, // Centrar el texto en las celdas de encabezado
      ),
    );
  }

  static pw.Widget _buildDataCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          color: PdfColors.black,
          fontSize: 10,
        ),
        textAlign: pw.TextAlign.center, // Centrar el texto en las celdas de datos
      ),
    );
  }
}