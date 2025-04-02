import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/auth/controllers/report_config.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_sublimacion_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/top_bar.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/sublimacion_table.dart';
//import 'package:remixicon/remixicon.dart';

class SublimacionScreen extends StatefulWidget {
  const SublimacionScreen({Key? key}) : super(key: key);

  @override
  _SublimacionScreenState createState() => _SublimacionScreenState();
}

class _SublimacionScreenState extends State<SublimacionScreen> {
  final GlobalKey<SublimacionTableState> _sublimacionTableKey = GlobalKey<SublimacionTableState>();

  void _navigateToAddProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const AddSublimacionScreen(),
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
    title: "Reporte de Sublimación",
    collection: "sublimacion",
    headers: ["Cantidad", "Artículo", "Marca", "Modelo", "Especificaciones", "N° Producto", "N° Serie", "Antigüedad", "Valor Aproximado", "Responsable", "Recibo / Instructivo", "Ubicación"],
    fields: ["cantidad", "articulo", "marca", "modelo", "especificaciones", "numero_producto", "numero_serie", "antiguedad", "valor_aprox", "responsable", "recibo", "ubicacion"],
  ),
      onSearch: (query) => _sublimacionTableKey.currentState?.updateSearchQuery(query),
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
        title: TopBar(title: "Sublimación"), // Aquí usamos el TopBar
      ),
      drawer: const Sidebar(),
      body: Column(
        children: [
          _buildActionButtons(),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SublimacionTable(key: _sublimacionTableKey),
            ),
          ),
        ],
      ),
    );
  }
}