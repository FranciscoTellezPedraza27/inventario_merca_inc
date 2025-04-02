import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/cocina_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/herramientas_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/limpieza_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/mobiliario_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/otros_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/oxxoadultos_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/oxxokids_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/produccion_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/historial_screen.dart';
import '../modules/auth/views/login_page.dart';
import '../modules/dashboard/views/dashboard_screen.dart';
import '../modules/dashboard/views/electronics_screen.dart';
import '../modules/dashboard/views/papeleria_screen.dart';
import '../modules/dashboard/views/sublimacion_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String electronica = '/electronic';
  static const String papeleria = '/papeleria';
  static const String sublimacion = '/sublimacion';
  static const String mobiliario = '/mobiliario';
  static const String cocina = '/cocina';
  static const String limpieza = '/limpieza';
  static const String herramientas = '/herramientas';
  static const String produccion = '/produccion';
  static const String otros = '/otros';
  static const String oxxoKids = '/oxxo_k';
  static const String oxxoAdultos = '/oxxo_a';
  static const String historial = '/historial';
}

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.login: (context) => LoginScreen(),
  AppRoutes.dashboard: (context) => DashboardScreen(),
  AppRoutes.electronica: (context) => ElectronicsScreen(),
  AppRoutes.papeleria: (context) => PapeleriaScreen(),
  AppRoutes.sublimacion: (context) => SublimacionScreen(),
  AppRoutes.mobiliario: (context) => MobiliarioScreen(),
  AppRoutes.cocina: (context) => CocinaScreen(),
  AppRoutes.limpieza: (context) => LimpiezaScreen(),
  AppRoutes.herramientas: (context) => HerramientasScreen(),
  AppRoutes.produccion: (context) => ProduccionScreen(),
  AppRoutes.otros: (context) => OtrosScreen(),
  AppRoutes.oxxoKids: (context) => OxxoKidsScreen(),
  AppRoutes.oxxoAdultos: (context) => OxxoAdultosScreen(),
  AppRoutes.historial: (context) => HistorialScreen(),
};

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      case AppRoutes.electronica:
        return MaterialPageRoute(builder: (_) => ElectronicsScreen());
      case AppRoutes.papeleria:
        return MaterialPageRoute(builder: (_) => PapeleriaScreen());
      case AppRoutes.sublimacion:
        return MaterialPageRoute(builder: (_) => SublimacionScreen());
      case AppRoutes.mobiliario:
        return MaterialPageRoute(builder: (_) => MobiliarioScreen());
      case AppRoutes.cocina:
        return MaterialPageRoute(builder: (_) => CocinaScreen());
      case AppRoutes.limpieza:
        return MaterialPageRoute(builder: (_) => LimpiezaScreen());
      case AppRoutes.herramientas:
        return MaterialPageRoute(builder: (_) => HerramientasScreen());
      case AppRoutes.produccion:
        return MaterialPageRoute(builder: (_) => ProduccionScreen());
      case AppRoutes.otros:
        return MaterialPageRoute(builder: (_) => OtrosScreen());
      case AppRoutes.oxxoKids:
        return MaterialPageRoute(builder: (_) => OxxoKidsScreen());
      case AppRoutes.oxxoAdultos:
        return MaterialPageRoute(builder: (_) => OxxoAdultosScreen());
      case AppRoutes.historial:
        return MaterialPageRoute(builder: (_) => HistorialScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('¡Ruta no encontrada!', style: TextStyle(color: Colors.red)),
      ),
      )
    );
  }
}