import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:remixicon/remixicon.dart';
import 'package:inventario_merca_inc/routes/app_routes.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar cierre de sesión"),
          backgroundColor: Colors.white,
          content: const Text("¿Estás seguro de que quieres cerrar sesión?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF009FE3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                )
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _signOut(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF971B81),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Drawer(
      child: Container(
        color: const Color(0xFF971B81),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "INVENTARIO MERCA INC",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSidebarItem(
                      context,
                      Remix.tv_line,
                      "Electrónicos",
                      AppRoutes.electronica,
                      currentRoute,
                    ),
                    _buildSidebarItem(
                      context,
                      Remix.draft_line,
                      "Papelería",
                      AppRoutes.papeleria,
                      currentRoute,
                    ),
                    _buildSidebarItem(
                      context,
                      Remix.printer_line,
                      "Sublimación",
                      AppRoutes.sublimacion,
                      currentRoute,
                    ),
                    _buildSidebarItem(
                      context,
                      Remix.armchair_line,
                      "Mobiliario",
                      AppRoutes.mobiliario,
                      currentRoute,
                    ),
                    _buildSidebarItem(
                      context,
                      Remix.cup_line,
                      "Cocina",
                      AppRoutes.cocina,
                      currentRoute,
                    ),
                    _buildSidebarItem(
                      context,
                      Remix.brush_4_line,
                      "Limpieza",
                      AppRoutes.limpieza,
                      currentRoute,
                    ),
                    _buildSidebarItem(
                      context,
                      Remix.hammer_line,
                      "Herramientas",
                      AppRoutes.herramientas,
                      currentRoute,
                    ),
                    _buildSidebarItem(
                      context,
                      Remix.clapperboard_line,
                      "Producción",
                      AppRoutes.produccion,
                      currentRoute,
                    ),
                    _buildSidebarItem(
                      context,
                      Remix.box_3_line,
                      "Otros",
                      AppRoutes.otros,
                      currentRoute,
                    ),
                    _buildSidebarItem(
                      context,
                      Remix.bear_smile_line,
                      "OXXO Kids",
                      AppRoutes.oxxoKids,
                      currentRoute,
                    ),
                    _buildSidebarItem(
                      context,
                      Remix.user_3_line,
                      "OXXO Adultos Mayores",
                      AppRoutes.oxxoAdultos,
                      currentRoute,
                    ),
                    _buildSidebarItem(
                      context,
                      Remix.history_line,
                      "Historial",
                      AppRoutes.historial,
                      currentRoute,
                    ),
                  ],
                ),
              ),
            ),
            _buildSidebarItem(
              context,
              Icons.exit_to_app,
              "Cerrar Sesión",
              '',
              currentRoute,
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
  BuildContext context,
  IconData icon,
  String title,
  String route,
  String currentRoute, {
  bool isLogout = false,
}) {
  final bool isSelected = currentRoute == route;

  return Container(
    decoration: BoxDecoration(
      color: isSelected ? const Color(0xFF7A1667) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: ListTile(
      leading: Icon(icon, color: Colors.white.withOpacity(isSelected ? 1 : 0.8)),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(isSelected ? 1 : 0.8),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (isLogout) {
          _confirmSignOut(context);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    ),
  );
}
  }