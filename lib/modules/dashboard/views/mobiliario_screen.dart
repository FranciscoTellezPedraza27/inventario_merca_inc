import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_mobiliario_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/mobiliario_table.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/top_bar.dart';

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
          TopBar(title: "Mobiliario"),
          SearchBarWidget(
            onAddProduct: () => _navigateToAddProduct(context),
            onSearch: (query) => _mobiliarioTableKey.currentState?.updateSearchQuery(query),
            onGeneratePDF: (){
              
            },
          ),
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
