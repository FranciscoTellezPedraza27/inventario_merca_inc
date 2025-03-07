import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/cocina_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/herramientas_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/limpieza_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/mobiliario_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/otros_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/oxxoadultos_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/oxxokids_screen.dart';
import 'package:inventario_merca_inc/modules/dashboard/views/produccion_screen.dart';
import '../modules/auth/views/login_page.dart';
import '../modules/dashboard/views/dashboard_screen.dart';
import '../modules/dashboard/views/electronics_screen.dart';
import '../modules/dashboard/views/papeleria_screen.dart';
import '../modules/dashboard/views/sublimacion_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (BuildContext context) => LoginScreen(), // Verifica que la clase exista
  '/dashboard': (BuildContext context) => DashboardScreen(),
};

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

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      case electronica:
        return MaterialPageRoute(builder: (_) => ElectronicsScreen());
      case papeleria:
        return MaterialPageRoute(builder: (_) => PapeleriaScreen());
      case sublimacion:
        return MaterialPageRoute(builder: (_) => SublimacionScreen());
      case mobiliario:
        return MaterialPageRoute(builder: (_) => MobiliarioScreen());
      case cocina:
        return MaterialPageRoute(builder: (_) => CocinaScreen());
      case limpieza:
        return MaterialPageRoute(builder: (_) => LimpiezaScreen());      
      case herramientas:
        return MaterialPageRoute(builder: (_) => HerramientasScreen()); 
      case produccion:
        return MaterialPageRoute(builder: (_) => ProduccionScreen());
      case otros:
        return MaterialPageRoute(builder: (_) => OtrosScreen());
      case oxxoKids:
        return MaterialPageRoute(builder: (_) => OxxoKidsScreen());
      case oxxoAdultos:
        return MaterialPageRoute(builder: (_) => OxxoAdultosScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(child: Text('Página no encontrada')),
                ));
    }
  }
}