import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_limpieza_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/limpieza_table.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/top_bar.dart';

class LimpiezaScreen extends StatefulWidget {
  const LimpiezaScreen({Key? key}) : super(key: key);

  @override
  _LimpiezaScreenState createState() => _LimpiezaScreenState();
}

class _LimpiezaScreenState extends State<LimpiezaScreen> {
  final GlobalKey<LimpiezaTableState> _limpiezaTableKey = GlobalKey<LimpiezaTableState>();

 void _navigateToAddProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const AddLimpiezaScreen(),
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
          TopBar(title: "Limpieza"),
          SearchBarWidget(
            onAddProduct: () => _navigateToAddProduct(context),
            onSearch: (query) => _limpiezaTableKey.currentState?.updateSearchQuery(query),
            onGeneratePDF: () {
              
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LimpiezaTable(key: _limpiezaTableKey),
            ),
          ),
        ],
      ),
    );
  }
}
