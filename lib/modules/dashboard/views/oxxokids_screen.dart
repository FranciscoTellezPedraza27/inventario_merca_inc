import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_oxxokids_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/oxxokids_table.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/top_bar.dart';

class OxxoKidsScreen extends StatefulWidget {
  const OxxoKidsScreen({Key? key}) : super(key: key);

  @override
  _OxxoKidsScreenState createState() => _OxxoKidsScreenState();
}

class _OxxoKidsScreenState extends State<OxxoKidsScreen> {
  final GlobalKey<OxxoKidsTableState> _oxxoKidsTableKey = GlobalKey<OxxoKidsTableState>();

 void _navigateToAddProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const AddOxxoKidsScreen(),
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
            onSearch: (query) => _oxxoKidsTableKey.currentState?.updateSearchQuery(query),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OxxoKidsTable(key: _oxxoKidsTableKey),
            ),
          ),
        ],
      ),
    );
  }
}
