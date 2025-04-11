import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:inventario_merca_inc/modules/auth/services/pdf_service.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/historial_table.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/top_bar.dart';
import 'package:printing/printing.dart';
import '../widgets/sidebar.dart';
import 'package:inventario_merca_inc/modules/auth/controllers/report_config.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({Key? key}) : super(key: key);

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  String _searchQuery = "";
  List<String> _categorias = [];
  String? _selectedCategoria = 'Todas';

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  void _cargarCategorias() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('historial')
        .orderBy('categoria')
        .get();

    final categorias = snapshot.docs
        .map((doc) => doc['categoria'] as String?)
        .where((c) => c != null)
        .toSet()
        .toList();

    setState(() {
      _categorias = ['Todas', ...categorias.cast<String>()];
    });
  }

  Future<void> _generarPDF() async {
    final pdfConfig = ReportConfig(
      title: "Reporte de Historial",
      collection: "historial",
      headers: [
        "Fecha",
        "Hora",
        "Usuario",
        "Categoría",
        "Tipo Mov.",
        "Campo",
        "Valor Anterior",
        "Valor Nuevo"
      ],
      fields: [
        "fecha",
        "hora",
        "usuario",
        "categoria",
        "tipo_movimiento",
        "campo",
        "valor_anterior",
        "valor_nuevo"
      ], // Exact match
    );

    try {
      final ByteData imageData =
          await rootBundle.load('lib/images/Hoja_Membretada.jpg');
      final Uint8List backgroundImage = imageData.buffer.asUint8List();

      final querySnapshot = await _getFilteredStream().first;

      final dateFormat = DateFormat('dd/MM/yyyy');
      final timeFormat = DateFormat('HH:mm:ss');

      final data = querySnapshot.docs.map((doc) {
        final raw = doc.data() as Map<String, dynamic>;
        final timestamp = raw['timestamp'] as Timestamp;
        print('[DEBUG] Documento Firestore: $raw');

        return {
          'fecha': dateFormat.format(timestamp.toDate()),
          'hora': timeFormat.format(timestamp.toDate()),
          'usuario': raw['usuario'] ?? 'Sistema',
          'categoria': raw['categoria'] ?? 'N/A',
          'tipo_movimiento': raw['tipo_movimiento'] ?? 'N/A',
          'campo': raw['campo'] ?? 'N/A',
          'valor_anterior': raw['valor_anterior']?.toString() ?? '-',
          'valor_nuevo': raw['valor_nuevo']?.toString() ?? '-',
        };
      }).toList();

      final pdfBytes = await PdfService.generatePDF(
        config: pdfConfig,
        data: data,
        backgroundImage: backgroundImage,
      );

      await Printing.layoutPdf(onLayout: (_) => pdfBytes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: ${e.toString()}')),
      );
    }
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    Query query = FirebaseFirestore.instance
        .collection('historial')
        .orderBy('timestamp', descending: true);

    if (_selectedCategoria != null && _selectedCategoria != 'Todas') {
      query = query.where('categoria', isEqualTo: _selectedCategoria);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 appBar: AppBar(
  toolbarHeight: 60,
  backgroundColor: Colors.white,
  elevation: 2,
  title: const TopBar( // ← Sin parámetros extra
    title: "Historial de Movimientos",
  ),
  leading: Builder(
    builder: (context) => IconButton(
      icon: const Icon(Icons.menu, color: Color(0xFF971B81)),
      onPressed: () => Scaffold.of(context).openDrawer(),
    ),
  ),
      ),
      drawer: const Sidebar(),
      body: Container(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 15, bottom: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF8E8F5)],
          ),
        ),
        child: Column(
          children: [
            // Barra de búsqueda y filtros (estilo de SearchBarWidget)
            Container(
              margin: EdgeInsets.zero, // ← Eliminar margen

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
              padding: const EdgeInsets.all(12.0),

              child: Row(
                children: [
                  const SizedBox(height: 8), // ← Reducir espacio

                  Expanded(
                    child: TextField(
                      onChanged: (query) =>
                          setState(() => _searchQuery = query),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        hintText: "Buscar en historial...",
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
                  const SizedBox(width: 10),
                  _buildDropdownCategorias(),
                  const SizedBox(width: 10),
                  _buildButton(
                    icon: Icons.picture_as_pdf,
                    label: "Generar PDF",
                    color: const Color(0xFF971B81),
                    onPressed: _generarPDF,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getFilteredStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return _buildErrorState(snapshot.error.toString());
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return _buildLoadingState();
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                      return _buildEmptyState();

                    return HistorialTable(
                      documentos: _aplicarFiltroBusqueda(snapshot.data!.docs),
                      searchQuery: _searchQuery,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCategorias() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.grey.shade100,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButton<String>(
        value: _selectedCategoria,
        underline: Container(),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF971B81)),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        items: _categorias.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedCategoria = value),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 20),
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

  Widget _buildLoadingState() => const Center(
        child: CircularProgressIndicator(color: Color(0xFF971B81)),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 15),
            Text(
              'No hay registros en el historial',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );

  Widget _buildErrorState(String error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 15),
            const Text('Error al cargar datos', style: TextStyle(fontSize: 16)),
            Text(error, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );

  List<QueryDocumentSnapshot> _aplicarFiltroBusqueda(
      List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final query = _searchQuery.toLowerCase();
      return query.isEmpty ||
          data['usuario'].toString().toLowerCase().contains(query) ||
          data['categoria'].toString().toLowerCase().contains(query);
    }).toList();
  }
}
