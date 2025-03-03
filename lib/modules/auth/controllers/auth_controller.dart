/*import 'package:flutter/material.dart';
import 'package:inventario_muebleria_byl/modules/auth/services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<void> login(
      {required String email,
      required String password,
      required BuildContext context}) async {
    
    // Verifica si los campos están vacíos
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    bool isAuthenticated = await _authService.authenticate(email, password);

    if (isAuthenticated) {
      Navigator.pushNamed(context, '/dashboard'); // Redirige al dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credenciales incorrectas, intenta de nuevo')),
      );
    }
  }
}
*/