import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(), // Menú lateral
          Expanded(
            child: Column(
              children: [
                TopBar(title: "Dashboard",), // Barra superior
                Expanded(
                  child: Center(
                    child: Text("Bienvenido al Dashboard"),
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
