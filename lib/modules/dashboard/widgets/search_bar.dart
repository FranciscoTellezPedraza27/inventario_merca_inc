import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/auth/controllers/report_config.dart';
import 'package:inventario_merca_inc/modules/auth/services/pdf_service.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchBarWidget extends StatelessWidget {
  final bool showAddButton;

  final VoidCallback onAddProduct;
  final Function(String) onSearch;
  final ReportConfig pdfConfig;

  const SearchBarWidget({
    this.showAddButton = true,
    super.key,
    required this.onAddProduct,
    required this.onSearch,
    required this.pdfConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    onChanged: onSearch,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      hintText: "Busca tu Producto",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
  if (showAddButton) ...[
    _buildButton(
      icon: Icons.add,
      label: "Agregar Producto",
      color: Colors.black,
      onPressed: onAddProduct,
    ),
    const SizedBox(width: 10),
                  _buildButton(
                    icon: Icons.picture_as_pdf,
                    label: "Generar PDF",
                    color: const Color(0xFF009FE3),
                    onPressed: () => _generatePDF(context),
                  ),
  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePDF(BuildContext context) async {
    try {
      // Obtener datos de Firestore usando la configuración
      final data = await FirebaseFirestore.instance
          .collection(pdfConfig.collection)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

      // Cargar imagen de fondo
      final ByteData imageData = await rootBundle.load('lib/images/Hoja_Membretada.jpg');
      final Uint8List backgroundImage = imageData.buffer.asUint8List();

      // Generar PDF usando la configuración
      final pdfBytes = await PdfService.generatePDF(
        config: pdfConfig,
        data: data,
        backgroundImage: backgroundImage,
      );

      // Mostrar diálogo de impresión
      await Printing.layoutPdf(onLayout: (_) => pdfBytes);
    } catch (e) {
      print("Error al generar PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al generar el PDF")),
      );
    }
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}