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
      .get();

  // Paso 1: Extraer categorías únicas y normalizar para filtrado
  final rawCategories = snapshot.docs
      .map((doc) => doc['categoria'] as String?)
      .where((c) => c != null && c.trim().isNotEmpty)
      .toList();

  // Paso 2: Normalizar para filtrado (sin espacios, tildes, etc.)
  final normalizedCategories = rawCategories.map((c) => c!
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâ]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöô]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll(RegExp(r'[^a-z0-9]'), '')
  ).toList();

  // Paso 3: Formatear para visualización (Dropdown)
  final Map<String, String> formatRules = {
    'oxxokids': 'OXXO Kids',
    'sublimacion': 'Sublimación',
    'papeleria': 'Papelería',
    'oxxoadultos': 'OXXO Adultos', // Agrega más reglas si necesitas
  };

  final formattedCategories = rawCategories.map((original) {
    final normalized = original!
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    
    return formatRules[normalized] ?? 
      original[0].toUpperCase() + original.substring(1).toLowerCase();
  }).toList();

  setState(() {
    _categorias = ['Todas', ...formattedCategories.toSet().toList()]; // Elimina duplicados
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
    ],
  );

  try {
    final ByteData imageData =
        await rootBundle.load('lib/images/Hoja_Membretada.jpg');
    final Uint8List backgroundImage = imageData.buffer.asUint8List();

    // 🔥 Traer todos los datos de Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('historial')
        .orderBy('timestamp', descending: true)
        .get();

    // 🔎 Aplicar el mismo filtrado que en pantalla
    final documentosFiltrados = _aplicarFiltroBusqueda(snapshot.docs);

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm:ss');

    final data = documentosFiltrados.map((doc) {
      final raw = doc.data() as Map<String, dynamic>;
      final timestamp = raw['timestamp'] as Timestamp;

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
  return FirebaseFirestore.instance
      .collection('historial')
      .orderBy('timestamp', descending: true)
      .snapshots();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const TopBar(title: "Historial de Movimientos"),
      ),
      drawer: const Sidebar(),
      body: Column(
        children: [
          _buildActionBar(),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
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
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (query) => setState(() => _searchQuery = query),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
            _buildPDFButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCategorias() {
    return Container(
      width: 200,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: DropdownButton<String>(
        value: _selectedCategoria,
        underline: Container(),
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF009FE3)),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(8),
        style: const TextStyle(
            color: Colors.black87, fontSize: 14, fontFamily: 'Poppins'),
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

  Widget _buildPDFButton() {
    return ElevatedButton.icon(
      onPressed: _generarPDF,
      icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
      label: const Text(
        "Generar PDF",
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF971B81),
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

      String _normalizarTexto(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâ]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöô]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll(RegExp(r'[^a-z0-9]'), '') // Elimina caracteres especiales
      .replaceAll(' ', ''); // Elimina espacios
}

List<QueryDocumentSnapshot> _aplicarFiltroBusqueda(List<QueryDocumentSnapshot> docs) {
  final searchQueryNormalized = _normalizarTexto(_searchQuery);
  final categoriaSeleccionadaNormalized = _selectedCategoria == 'Todas' 
      ? null 
      : _normalizarTexto(_selectedCategoria!);

  return docs.where((doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // 1. Filtrar por categoría normalizada
    if (categoriaSeleccionadaNormalized != null) {
      final categoriaDoc = _normalizarTexto(data['categoria']?.toString() ?? '');
      if (categoriaDoc != categoriaSeleccionadaNormalized) {
        return false;
      }
    }

    // 2. Filtrar por búsqueda en múltiples campos
    if (searchQueryNormalized.isNotEmpty) {
      final usuario = _normalizarTexto(data['usuario']?.toString() ?? '');
      final categoria = _normalizarTexto(data['categoria']?.toString() ?? '');
      final tipoMovimiento = _normalizarTexto(data['tipo_movimiento']?.toString() ?? '');
      final campo = _normalizarTexto(data['campo']?.toString() ?? '');
      final valorAnterior = _normalizarTexto(data['valor_anterior']?.toString() ?? '');
      final valorNuevo = _normalizarTexto(data['valor_nuevo']?.toString() ?? '');

      final camposConcatenados = [
        usuario,
        categoria,
        tipoMovimiento,
        campo,
        valorAnterior,
        valorNuevo,
      ].join(' ');

      if (!camposConcatenados.contains(searchQueryNormalized)) {
        return false;
      }
    }

    return true;
  }).toList();
}
}