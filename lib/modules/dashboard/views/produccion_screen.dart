import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/auth/controllers/report_config.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_produccion_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/produccion_table.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/top_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const Sidebar(),
      body: Column(
        children: [
          TopBar(title: "Producción"),
          SearchBarWidget(
            onAddProduct: () => _navigateToAddProduct(context),
            onSearch: (query) => _produccionTableKey.currentState?.updateSearchQuery(query),
 pdfConfig: ReportConfig(
    title: "Reporte de Papelería",
    collection: "papeleria",
    headers: ["Cantidad", "Material", "Tipo", "Color", "Proveedor"],
    fields: ["cantidad", "material", "tipo", "color", "proveedor"],
  ),
          ),
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
