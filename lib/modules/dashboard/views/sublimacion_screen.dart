import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_sublimacion_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/search_bar.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/sidebar.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/sublimacion_table.dart';
import '../widgets/top_bar.dart';


class SublimacionScreen extends StatefulWidget {
  @override
  _SublimacionScreenState createState() => _SublimacionScreenState();
}

class _SublimacionScreenState extends State<SublimacionScreen> {
  final GlobalKey<SublimacionTableState> _sbulimacionTableKey = GlobalKey<SublimacionTableState>();

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
          TopBar(title: "Sublimación"),
          SearchBarWidget(
            onAddProduct: () => _navigateToAddProduct(context),
            onSearch: (query) => _sbulimacionTableKey.currentState?.updateSearchQuery(query),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SublimacionTable(key: _sbulimacionTableKey),
            ),
          ),
        ],
      ),
    );
  }
}
