import 'package:flutter/material.dart';
import '../modules/auth/views/login_page.dart';
import '../modules/dashboard/views/dashboard_screen.dart';
import '../modules/dashboard/views/electronics_screen.dart';
import '../modules/dashboard/views/orders_screen.dart';
import '../modules/dashboard/views/record_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (BuildContext context) => LoginScreen(), // Verifica que la clase exista
  '/dashboard': (BuildContext context) => DashboardScreen(),
};

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String inventory = '/electronic';
  static const String orders = '/orders';
  static const String pending = '/record';
  static const String users = '/users';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      case inventory:
        return MaterialPageRoute(builder: (_) => ElectronicsScreen());
      case orders:
        return MaterialPageRoute(builder: (_) => OrdersView());
      case pending:
        return MaterialPageRoute(builder: (_) => RecordView());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(child: Text('Página no encontrada')),
                ));
    }
  }
}