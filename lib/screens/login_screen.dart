/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventario_muebleria_byl/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Verifica si los campos están vacíos
    if (email.isEmpty || password.isEmpty) {
      Navigator.pushReplacementNamed(context, '/dashboard');
      _showError("Por favor, completa todos los campos.");
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Navegar a la pantalla del dashboard después de iniciar sesión exitosamente
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      _showError("Error al iniciar sesión. Verifica tus credenciales.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Lado izquierdo - Imagen
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/Silla_Inicio.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Lado derecho - Formulario de login
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'B&L MUEBLES',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Iniciar Sesión',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    label: 'Correo',
                    isPassword: false,
                    controller: _emailController,
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    label: 'Contraseña',
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Continuar'),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        '¿Aún no tienes una cuenta? Regístrate',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/