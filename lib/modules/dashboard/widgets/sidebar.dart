import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar cierre de sesión"),
          backgroundColor: Colors.white,
          content: Text("¿Estás seguro de que quieres cerrar sesión?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cerrar el diálogo
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
                _signOut(context); // Cerrar sesión
              },
              child: Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Regresa al login
  }

  @override
Widget build(BuildContext context) {
  return Drawer(
    child: Container(
      color: Color(0xFF971B81), // Fondo del Sidebar
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            "INVENTARIO MERCA INC",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Color del texto en blanco
            ),
          ),
          const SizedBox(height: 20),
          _sidebarItem(context, Feather.home, "Inicio", '/dashboard'),
          _sidebarItem(context, Feather.package, "Electrónicos", '/electronic'),
          _sidebarItem(context, Feather.truck, "Pedidos", '/orders'),
          _sidebarItem(context, Feather.bar_chart_2, "Historial", '/pending'),
          _sidebarItem(context, Feather.user, "Usuarios", '/users'),
          Spacer(),
          _sidebarItem(context, Icons.exit_to_app, "Cerrar Sesión", '', isLogout: true),
        ],
      ),
    ),
  );
}



  Widget _sidebarItem(BuildContext context, IconData icon, String title, String route, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // Cerrar el Drawer
        if (isLogout) {
          _confirmSignOut(context);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
