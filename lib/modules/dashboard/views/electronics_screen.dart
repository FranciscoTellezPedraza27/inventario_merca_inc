import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_electronic_screen.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/electronics_table.dart';
import '../widgets/top_bar.dart';

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
          TopBar(title: "Electrónicos"),
          SearchBarWidget(
            onAddProduct: () => _navigateToAddProduct(context),
            onSearch: (query) => _electronicTableKey.currentState?.updateSearchQuery(query),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElectronicTable(key: _electronicTableKey),
            ),
          ),
        ],
      ),
    );
  }
}
