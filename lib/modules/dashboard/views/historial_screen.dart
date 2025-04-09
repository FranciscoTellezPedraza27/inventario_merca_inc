import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario_merca_inc/modules/auth/controllers/report_config.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/historial_table.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/top_bar.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({Key? key}) : super(key: key);

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final GlobalKey<HistorialTableState> _historialTableKey = GlobalKey();

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SearchBarWidget(
        showAddButton: false,
        onAddProduct: () {}, // Función vacía
        pdfConfig: ReportConfig(
          title: "Reporte de Historial",
          collection: "historial",
          headers: ["Fecha", "Hora", "Usuario", "Categoría", "Campo", "Tipo Mov.", "Valor Anterior", "Valor Nuevo"],
          fields: ["timestamp", "usuario", "categoria", "campo", "tipo_movimiento", "valor_anterior", "valor_nuevo"],
        ),
        onSearch: (query) => _historialTableKey.currentState?.updateSearchQuery(query),
      ),
    );
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
        title: TopBar(title: "Historial de Movimientos"),
      ),
      drawer: const Sidebar(),
      body: Column(
        children: [
          _buildActionButtons(),
          const SizedBox(height: 10),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('historial')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No hay registros en el historial'),
                    );
                  }

                  return HistorialTable(
                    key: _historialTableKey,
                    documentos: snapshot.data!.docs,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}