import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/auth/controllers/report_config.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_produccion_screen.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/produccion_table.dart';
import '../widgets/top_bar.dart'; // Asegúrate de importar el TopBar

class ProduccionScreen extends StatefulWidget {
  const ProduccionScreen({Key? key}) : super(key: key);

  @override
  _ProduccionScreenState createState() => _ProduccionScreenState();
}

class _ProduccionScreenState extends State<ProduccionScreen> {
  final GlobalKey<ProduccionTableState> _produccionTableKey = GlobalKey<ProduccionTableState>();

  void _navigateToAddProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const AddProduccionScreen(),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SearchBarWidget(
        onAddProduct: () => _navigateToAddProduct(context),
        pdfConfig: ReportConfig(
          title: "Reporte de Producción",
          collection: "produccion",
          headers: ["Cantidad", "Artículo", "Marca", "Modelo", "Especificaciones", "N° Producto", "N° Serie", "Antigüedad", "Valor Aproximado", "Responsable", "Recibo / Instructivo", "Ubicación"],
          fields: ["cantidad", "articulo", "marca", "modelo", "especificaciones", "numero_producto", "numero_serie", "antiguedad", "valor_aprox", "responsable", "recibo", "ubicacion"],
        ),
        onSearch: (query) => _produccionTableKey.currentState?.updateSearchQuery(query),
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
        title: TopBar(title: "Producción"), // Aquí usamos el TopBar
      ),
      drawer: const Sidebar(),
      body: Column(
        children: [
          _buildActionButtons(),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProduccionTable(key: _produccionTableKey),
            ),
          ),
        ],
      ),
    );
  }
}