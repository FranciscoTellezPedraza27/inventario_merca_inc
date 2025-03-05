import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_papeleria_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/papeleria_table.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/top_bar.dart';

class PapeleriaView extends StatefulWidget {
  @override
  _PapeleriaViewState createState() => _PapeleriaViewState();
}

class _PapeleriaViewState extends State<PapeleriaView> {
  final GlobalKey<PapeleriaTableState> _papeleriaTableKey = GlobalKey<PapeleriaTableState>();

 void _navigateToAddProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.red,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const AddPapeleriaScreen(),
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
            onSearch: (query) => _papeleriaTableKey.currentState?.updateSearchQuery(query),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PapeleriaTable(key: _papeleriaTableKey),
            ),
          ),
        ],
      ),
    );
  }
}
