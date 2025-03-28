import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/auth/controllers/report_config.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_mobiliario_screen.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/mobiliario_table.dart';
//import 'package:remixicon/remixicon.dart';

class MobiliarioScreen extends StatefulWidget {
  const MobiliarioScreen({Key? key}) : super(key: key);

  @override
  _MobiliarioScreenState createState() => _MobiliarioScreenState();
}

class _MobiliarioScreenState extends State<MobiliarioScreen> {
  final GlobalKey<MobiliarioTableState> _mobiliarioTableKey = GlobalKey<MobiliarioTableState>();

  void _navigateToAddProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const AddMobiliarioScreen(),
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
      onSearch: (query) => _mobiliarioTableKey.currentState?.updateSearchQuery(query),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    toolbarHeight: 60, // Altura del AppBar
    backgroundColor: Colors.white, // Color de fondo
    title: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Padding horizontal
      child: const Text("Mobiliario"),
    ),
    leading: Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    ),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300)
        ),
      ),
    ),
  ),
  drawer: const Sidebar(),
  body: Column(
    children: [
      _buildActionButtons(),
      const SizedBox(height: 10),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: MobiliarioTable(key: _mobiliarioTableKey),
        ),
      ),
    ],
  ),
);
  }
}