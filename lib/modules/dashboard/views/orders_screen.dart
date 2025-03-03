import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/add_order_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/widgets/order_table.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart';
import '../widgets/top_bar.dart';

class OrdersView extends StatefulWidget {
  @override
  _OrdersViewState createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  final GlobalKey<OrderTableState> _orderTableKey = GlobalKey<OrderTableState>();


  void _navigateToAddProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const AddOrderScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TopBar(title: "Pedidos"),
                SearchBarWidget(
                  onAddProduct: () => _navigateToAddProduct(context),
                  onSearch: (query) => _orderTableKey.currentState?.updateSearchQuery(query),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OrderTable(key: _orderTableKey), // Conectar con la tabla
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
