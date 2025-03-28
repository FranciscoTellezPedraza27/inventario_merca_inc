import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/firebase_options.dart';
import 'package:inventario_merca_inc/routes/app_routes.dart';
import 'package:inventario_merca_inc/constants/theme.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:inventario_muebleria_byl/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase inicializado correctamente");
  } catch (e) {
    print("❌ Error al inicializar Firebase: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme, 
      initialRoute: '/login', 
      onGenerateRoute: RouteGenerator.generateRoute,  // Referencia correcta al generador
      routes: appRoutes,  // Agregar este parámetro
    );
  }
}
