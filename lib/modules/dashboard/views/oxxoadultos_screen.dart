import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/auth/controllers/report_config.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_oxxoadultos_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/oxxoadultos_table.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/top_bar.dart';

class OxxoAdultosScreen extends StatefulWidget {
  const OxxoAdultosScreen({Key? key}) : super(key: key);

  @override
  _OxxoAdultosScreenState createState() => _OxxoAdultosScreenState();
}

class _OxxoAdultosScreenState extends State<OxxoAdultosScreen> {
  final GlobalKey<OxxoAdultosTableState> _oxxoAdultosTableKey = GlobalKey<OxxoAdultosTableState>();

 void _navigateToAddProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const AddOxxoAdultosScreen(),
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
          TopBar(title: "Papelería"),
          SearchBarWidget(
            onAddProduct: () => _navigateToAddProduct(context),
            onSearch: (query) => _oxxoAdultosTableKey.currentState?.updateSearchQuery(query),
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
              child: OxxoAdultosTable(key: _oxxoAdultosTableKey),
            ),
          ),
        ],
      ),
    );
  }
}
