import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/auth/controllers/report_config.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_electronic_screen.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/electronics_table.dart';
import '../widgets/top_bar.dart'; // Asegúrate de importar el TopBar

class ElectronicsScreen extends StatefulWidget {
  const ElectronicsScreen({Key? key}) : super(key: key);

  @override
  _ElectronicsScreenState createState() => _ElectronicsScreenState();
}

class _ElectronicsScreenState extends State<ElectronicsScreen> {
  final GlobalKey<ElectronicTableState> _electronicTableKey = GlobalKey<ElectronicTableState>();

  void _navigateToAddProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const AddElectronicScreen(),
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
          title: "Reporte de Electrónicos",
          collection: "electronicos",
          headers: ["Cantidad", "Artículo", "Marca", "Modelo", "Especificaciones", "N° Producto", "N° Serie", "Antigüedad", "Valor Aproximado", "Responsable", "Responsabilidad", "Ubicación"],
          fields: ["cantidad", "articulo", "marca", "modelo", "especificaciones", "numero_producto", "numero_serie", "antiguedad", "valor_aprox", "responsable", "responsabilidad", "ubicacion"],
        ),
        onSearch: (query) => _electronicTableKey.currentState?.updateSearchQuery(query),
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
        title: TopBar(title: "Electrónicos"), // Aquí usamos el TopBar
      ),
      drawer: const Sidebar(),
      body: Column(
        children: [
          _buildActionButtons(),
          const SizedBox(height: 10),
          Expanded(
              child: ElectronicTable(key: _electronicTableKey),
          ),
        ],
      ),
    );
  }
}